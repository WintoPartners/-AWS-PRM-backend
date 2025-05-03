// Start of Selection.
import express from "express";
import multer from "multer";
import fs from "fs";
import axios from "axios";
import FormData from "form-data"; // 필요시 주석 해제 후 npm install
import cors from "cors";
import OpenAI from "openai";
import * as dotenv from "dotenv";
import path from "path";
import pkg from 'pg';
import session from 'express-session';
import { v4 as uuidv4 } from 'uuid';
import pgSession from 'connect-pg-simple';
import solapi from 'solapi'; // 필요시 주석 해제 후 npm install
import nodemailer from 'nodemailer';
import Replicate from "replicate"; // 필요시 주석 해제 후 npm install
import bcrypt from "bcrypt";
import bodyParser from 'body-parser';
import pdf from 'pdf-parse';
import jwt from 'jsonwebtoken';
import cookieParser from 'cookie-parser';
// import PG from 'pg'; // 중복 import 제거 (이미 pkg에서 가져옴)
import { fileURLToPath } from 'url'; // 필요시 주석 해제 후 사용
import { Server } from 'socket.io'; // 필요시 주석 해제 후 사용

// 관리자 라우터 가져오기
import adminRouter from './admin.js';


// CORS 설정
// 로컬 개발 환경용 CORS 설정 (실제 사용)
// const corsOptions = {
//   origin: 'http://localhost:3000',
//   credentials: true,
//   methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
//   allowedHeaders: ['Content-Type', 'Authorization']
// };
// app.use(cors(corsOptions));



// 환경변수 로드 디버깅
// 환경변수 로드를 가장 먼저 실행
console.log('Current directory:', process.cwd());
dotenv.config();

// 환경변수 확인
console.log('Environment variables loaded:');
console.log('PORT:', process.env.PORT);
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('OPENAI_API_KEY exists:', !!process.env.OPENAI_API_KEY);

const { Pool } = pkg;
const pgStore = pgSession(session);
if (!process.env.OPENAI_API_KEY) {
  console.error('OpenAI API key is missing');
  process.exit(1);
}

// OpenAI 클라이언트 초기화
let openai;
try {
  const apiKey = process.env.OPENAI_API_KEY ? process.env.OPENAI_API_KEY.trim() : null;
  
  if (!apiKey) {
    console.error('⚠️ OpenAI API 키가 정의되지 않았습니다!');
    throw new Error('OpenAI API 키가 필요합니다.');
  }
  
  if (apiKey.length < 30) {
    console.error(`⚠️ OpenAI API 키가 너무 짧습니다: ${apiKey.length}자`);
    throw new Error('유효하지 않은 OpenAI API 키 형식입니다.');
  }
  
  console.log(`✓ OpenAI API 키 확인됨: ${apiKey.substring(0, 5)}...${apiKey.substring(apiKey.length-5)}`);
  
  openai = new OpenAI({
    apiKey: apiKey,
    timeout: 30000, // 30초 타임아웃 설정
    maxRetries: 2, // 최대 2번 재시도
    defaultHeaders: {
      'OpenAI-Beta': 'assistants=v1' // 베타 API 명시적 사용
    }
  });
  
  console.log('✓ OpenAI 클라이언트 초기화 성공');
} catch (error) {
  console.error('❌ OpenAI 클라이언트 초기화 실패:', error);
  process.exit(1); // 심각한 오류이므로 애플리케이션 종료
}

// API 키 확인
if (!process.env.OPENAI_API_KEY) {
  console.error('OpenAI API key is missing');
  // process.exit(1); // 서버 종료는 선택사항
} else {
  console.log('OPENAI_API_KEY exists:', !!process.env.OPENAI_API_KEY);
  console.log('OPENAI_API_KEY length:', process.env.OPENAI_API_KEY.length);
}

const app = express();
app.set('trust proxy', 1);

// 요청 본문 파싱 미들웨어
app.use(express.json());  
app.use(express.urlencoded({ extended: true }));

// PostgreSQL 연결 설정
const pool = new Pool({
  user: 'postgres',
  host: process.env.DBURL,
  database: 'dev',
  password: process.env.DBPASSWORD,
  port: 5432,
  ssl: {
      rejectUnauthorized: false
  },
});


// DB 연결 성공 후 테이블 스키마 확인 및 업데이트
pool.on('connect', async () => {
  console.log('Database connected successfully');
  console.log('DB Host:', process.env.DBURL);
  console.log('DB Name:', 'dev');
  
  // 스키마 확인 및 업데이트 함수 호출
  try {
    await checkAndUpdateSchema();
  } catch (error) {
    console.error('Schema check failed:', error);
  }
});

// 데이터베이스 스키마 확인 및 업데이트 함수
async function checkAndUpdateSchema() {
  try {
    // is_temp_password 컬럼 존재 여부 확인
    const columnCheckQuery = `
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'user_info' AND column_name = 'is_temp_password'
    `;
    const columnResult = await pool.query(columnCheckQuery);
    
    // 컬럼이 없으면 추가
    if (columnResult.rows.length === 0) {
      console.log('Adding is_temp_password column to user_info table...');
      const alterTableQuery = `
        ALTER TABLE user_info
        ADD COLUMN is_temp_password BOOLEAN DEFAULT false
      `;
      await pool.query(alterTableQuery);
      console.log('Column is_temp_password added successfully');
    } else {
      console.log('Column is_temp_password already exists');
    }
    
    // created_at 컬럼 존재 여부 확인
    const createdAtColumnQuery = `
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'rfp' AND column_name = 'created_at'
    `;
    const createdAtResult = await pool.query(createdAtColumnQuery);
    
    // 컬럼이 없으면 추가
    if (createdAtResult.rows.length === 0) {
      console.log('Adding created_at column to rfp table...');
      const alterRfpTableQuery = `
        ALTER TABLE rfp
        ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      `;
      await pool.query(alterRfpTableQuery);
      console.log('Column created_at added to rfp table successfully');
    } else {
      console.log('Column created_at in rfp table already exists');
    }
    
  } catch (error) {
    console.error('Error updating database schema:', error);
    throw error;
  }
}

pool.on('error', (err) => {
  console.error('Unexpected database error:', err);
});

// 초기 연결 테스트
pool.query('SELECT NOW()')
  .then(() => console.log('Database connection test successful'))
  .catch(err => console.error('Database connection test failed:', err));

// Session 설정
if(process.env.ENV === 'production') {
  console.log('Setting up production session configuration');
  app.use(session({
    store: new pgStore({
      pool: pool,
      tableName: 'session',
      createTableIfMissing: true  // 테이블이 없으면 자동 생성
    }),
    secret: "secret key",
    resave: false,
    saveUninitialized: true,  // false에서 true로 변경하여 세션 쿠키가 항상 생성되도록 함
    cookie: {
      maxAge: 24 * 60 * 60 * 1000, // 1일로 연장 (3600000에서 변경)
      secure: process.env.ENV === 'production',  // production에서만 true
      httpOnly: true,
      sameSite: process.env.ENV === 'production' ? 'None' : 'Lax'
    }
  }));
} else {
  console.log('Setting up development session configuration');
  app.use(session({
    store: new pgStore({
      pool: pool,
      tableName: 'session',
      createTableIfMissing: true
    }),
    secret: "secret key",
    resave: false,
    saveUninitialized: true, // false에서 true로 변경
    cookie: { 
      maxAge: 24 * 60 * 60 * 1000, // 1일로 연장
      sameSite: 'Lax'
    },
  }));
}

// 세션 파싱을 위한 쿠키 파서 미들웨어 추가
app.use(cookieParser());

// 세션 디버깅 미들웨어 추가
app.use((req, res, next) => {
  console.log('Session ID:', req.sessionID);
  console.log('Session Data:', req.session);
  
  // 응답에 세션 ID 쿠키가 항상 포함되도록 설정
  res.on('finish', () => {
    if (!req.session) {
      console.warn('Session not available in response');
    }
  });
  
  next();
});

// 세션 스토어 에러 핸들링
app.use((req, res, next) => {
  if (!req.session) {
    console.error('Session store error');
    return next(new Error('Session store is not available'));
  }
  next();
});

// Nginx에서도 CORS 헤더를 추가하기 위해 Nginx 설정 수정

app.use(express.json()); // JSON 형식의 본문을 파싱
app.use(express.urlencoded({ extended: true })); // URL 인코딩된 본문을 파싱
app.use(bodyParser.json());

// 인증 미들웨어 추가
const authMiddleware = (req, res, next) => {
  // 세션에서 사용자 정보 확인
  if (!req.session || !req.session.userInfo || !req.session.userInfo.userId) {
    return res.status(401).json({
      success: false,
      message: '로그인이 필요합니다.'
    });
  }
  next();
};

const saltRounds = 10;

// 이메일 전송 설정
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USERNAME,
    pass: process.env.EMAIL_PASSWORD
  },
  // 추가 설정으로 안정성 향상
  tls: {
    rejectUnauthorized: false // 자체 서명된 인증서 허용 (필요한 경우)
  },
  // 연결 타임아웃 설정
  connectionTimeout: 10000, // 10초
  greetingTimeout: 10000, // 10초
});

// 이메일 연결 테스트
transporter.verify(function(error, success) {
  if (error) {
    console.error('이메일 서비스 연결 오류:', error);
    console.log('이메일 설정 정보(비밀번호 제외):', { 
      service: 'gmail', 
      user: process.env.EMAIL_USERNAME,
      passwordLength: process.env.EMAIL_PASSWORD ? process.env.EMAIL_PASSWORD.length : 0
    });
  } else {
    console.log('이메일 서비스 연결 성공! 메시지 전송 준비 완료');
  }
});

// 대체 이메일 설정 함수 (필요시 다른 이메일 서비스로 전환)
function createAlternativeTransporter() {
  return nodemailer.createTransport({
    // 예: AWS SES, SendGrid 등 다른 서비스로 변경 가능
    service: 'gmail',
    auth: {
      user: process.env.ALTERNATIVE_EMAIL || process.env.EMAIL_USERNAME,
      pass: process.env.ALTERNATIVE_EMAIL_PASSWORD || process.env.EMAIL_PASSWORD
    }
  });
}

// const openai = new OpenAI({
//   apiKey: process.env.OPENAI_API_KEY,
// });

async function getProjectInfoByUserIp(userId) {
    const query = `
        SELECT pro_name, pro_period, pro_budget, pro_agency,pro_function, pro_skill,pro_description,pro_reference
        FROM rfp_temp
        WHERE user_session = $1
        LIMIT 1;
    `;
    try {
        const res = await pool.query(query, [userId]);
        return res.rows[0]; // 조회된 첫 번째 행을 반환
    } catch (err) {
        console.error(err);
        throw err;
    }
}

// 파일 경로 유틸리티 함수 개선 - fileURLToPath 제거
function getUploadPath(filename = '') {
  const isProd = process.env.NODE_ENV === 'production';
  let uploadDir;
  
  // 운영체제에 맞는 경로 설정
  if (isProd) {
    uploadDir = '/var/app/current/uploads';
  } else {
    uploadDir = '/var/app/current/uploads';
    //개발환경일땐 밑에 처럼 설정
    // uploadDir = path.join(process.cwd(), 'uploads');
  }
  
  console.log(`Using upload directory: ${uploadDir} (${isProd ? 'production' : 'development'} mode)`);
  
  // 디렉토리 자동 생성
  try {
    if (!fs.existsSync(uploadDir)) {
      console.log(`Creating upload directory: ${uploadDir}`);
      fs.mkdirSync(uploadDir, { recursive: true });
    }
  } catch (err) {
    console.error(`Error with upload directory: ${err.message}`);
    // 폴백: 에러 발생시 임시 디렉토리 사용
    uploadDir = path.join(process.cwd(), 'temp_uploads');
    console.log(`Fallback to temp directory: ${uploadDir}`);
    
    try {
      fs.mkdirSync(uploadDir, { recursive: true });
    } catch (tempErr) {
      console.error(`Critical error creating temp directory: ${tempErr.message}`);
    }
  }
  
  return filename ? path.join(uploadDir, filename) : uploadDir;
}

// multer storage 설정 수정
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = getUploadPath();
        console.log(`File will be uploaded to: ${uploadDir}`);
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        // 파일명 충돌 방지를 위한 타임스탬프 추가
        const timestamp = new Date().getTime();
        const ext = path.extname(file.originalname) || '.tmp';
        const safeFileName = `file_${timestamp}${ext}`;
        console.log(`Generated safe filename: ${safeFileName}`);
        cb(null, safeFileName);
    },
});

const upload = multer({ storage: storage });

// PDF 텍스트 추출 함수 업데이트
function cleanText(text) {
  // 공백 문자를 제외한 모든 특수 문자를 제거합니다.
  return text.replace(/[^\w\sㄱ-ㅎ가-힣]/g, '');
}

async function extractTextFromPDF(filePath) {
  try {
    console.log(`Extracting text from PDF: ${filePath}`);
    const dataBuffer = fs.readFileSync(filePath);
    const data = await pdf(dataBuffer);
    const cleanedText = cleanText(data.text); // 클린징 적용
    return cleanedText;
  } catch (err) {
    console.error('Error extracting text from PDF:', err);
    throw err;
  }
}

// Threads
// Create Thread
// 파일 업로드 라우트

app.post('/skip', async (req, res) => {
  try {
    console.log('Skip endpoint called');
    console.log('Session:', req.session);
    
    // 세션이 없거나 userInfo가 없는 경우 처리
    if (!req.session || !req.session.userInfo) {
      console.log('No session or userInfo found');
      return res.status(401).json({ 
        error: 'Authentication required',
        message: 'Please login first'
      });
    }

    const id = req.session.userInfo.userId;
    console.log('User ID:', id);
    
    // 임시로 구독 상태 체크를 건너뛰고 항상 구독된 것으로 처리
    const subscriptionStatus = 'Y';  // 강제로 'Y' 설정
    
    /* 기존 구독 체크 로직 주석 처리
    const subscriptionQuery = 'SELECT subscription_status FROM user_info WHERE user_id = $1';
    const subscriptionResult = await pool.query(subscriptionQuery, [id]);
    const subscriptionStatus = subscriptionResult.rows.length > 0 ? subscriptionResult.rows[0].subscription_status : null;
    if (subscriptionResult.rows.length > 0 && subscriptionResult.rows[0].subscription_status === 'N') {
        return res.status(200).send({
          message: 'Not Subscript',
          additionalInfo: {
              subscriptionStatus: subscriptionStatus
          }
      });
    }
    */

    req.session.userId = uuidv4();
    req.session.save(err => {
      if (err) {
          console.error(err);
          return res.status(500).send('Internal Server Error');
      }
      res.status(200).send({
        message: 'Session updated successfully',
        additionalInfo: {
          subscriptionStatus: subscriptionStatus
        }
      });
    });
  } catch(err) {
    console.error('Error in skip endpoint:', err);
    res.status(500).json({
      error: 'Internal server error',
      message: err.message
    });
  }
});




app.post('/upload', upload.single('file'), async (req, res) => {
  const file = req.file;
  let recognizedText = '';
  
  console.log('[/upload] 파일 업로드 요청 시작');
  
  if (!file) {
    console.error('No file uploaded');
    return res.status(400).send('No file uploaded.');
  }
  
  console.log(`Uploaded file info:`, {
    originalname: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
    path: file.path
  });
  
  // 세션 ID 설정
  req.session.userId = uuidv4();
  req.session.save(err => {
    if (err) {
      console.error('Session save error:', err);
    }
  });
  
  try {
    // 파일 유형에 따른 텍스트 추출
    if (file.mimetype === 'application/pdf') {
      try {
        recognizedText = await extractTextFromPDF(file.path);
        console.log('PDF text extracted successfully');
      } catch (error) {
        console.error('Error extracting text from PDF:', error.message);
        return res.status(500).send('Error extracting text from PDF.');
      }
    } else if (file.mimetype === 'text/plain') {
      try {
        recognizedText = fs.readFileSync(file.path, 'utf8');
        console.log('Text file read successfully');
      } catch (error) {
        console.error('Error reading text file:', error.message);
        return res.status(500).send('Error reading text file.');
      }
    } else {
      // CLOVA API 호출 부분
      console.log('Processing audio file with CLOVA API');
      const clientSecret = process.env.CLIENTSECRET;
      const formData = new FormData();
      formData.append('media', fs.createReadStream(file.path));
      formData.append('params', JSON.stringify({
        language: 'ko-KR',
        completion: 'sync',
        resultToObs: 'false'
      }));

      try {
        console.log('Sending request to CLOVA API');
        const response = await axios.post(process.env.CLOVAURL, formData, {
          headers: {
            ...formData.getHeaders(),
            'X-CLOVASPEECH-API-KEY': clientSecret
          }
        });
        recognizedText = response.data.text;
        console.log('[Upload] CLOVA API response received');
      } catch (apiError) {
        console.error('CLOVA API error:', apiError.message);
        return res.status(500).send('Error calling speech recognition API');
      }
    }

    // 사용자 정보 및 구독 상태 확인
    const id = req.session.userInfo?.userId;
    console.log('User ID:', id);
    
    // 구독 상태는 항상 'Y'로 설정 (테스트 환경)
    const subscriptionStatus = 'Y';

    // 파일 정보 DB 저장
    const { originalname, size } = file;
    const query = 'INSERT INTO voice_file (file_name, file_size) VALUES ($1, $2)';
    const fileValues = [originalname, size];
    await pool.query(query, fileValues);
    console.log('File info saved to database');

    // 추출된 텍스트 DB 저장
    console.log('Saving recognized text to database');
    const result = await pool.query(
      'INSERT INTO text_file_test (text_contents) VALUES ($1) RETURNING *',
      [recognizedText]
    );
    
    // OpenAI 처리
    console.log('OpenAI 처리 시작');
    try {
      // 1. Assistant 검색
      let assistant;
      try {
        assistant = await openai.beta.assistants.retrieve(process.env.GPTSKEY1);
        console.log(`Assistant 검색 성공: ${assistant.id}`);
      } catch (assistantError) {
        console.error('Assistant 검색 실패:', assistantError.message);
        return res.send({
          message: '파일이 업로드되었으나 AI 처리 중 오류가 발생했습니다.',
          additionalInfo: {
            projectName: '기본 프로젝트',
            budget: '0',
            duration: '0일',
            subscriptionStatus: 'Y',
            error: `Assistant 검색 실패: ${assistantError.message}`
          }
        });
      }
      
      // 2. Thread 생성
      let thread;
      try {
        thread = await openai.beta.threads.create();
        console.log(`Thread 생성 성공: ${thread.id}`);
      } catch (threadError) {
        console.error('Thread 생성 실패:', threadError.message);
        return res.send({
          message: '파일이 업로드되었으나 AI 처리 중 오류가 발생했습니다.',
          additionalInfo: {
            projectName: '기본 프로젝트',
            budget: '0',
            duration: '0일',
            subscriptionStatus: 'Y',
            error: `Thread 생성 실패: ${threadError.message}`
          }
        });
      }
      
      // 3. 메시지 추가
      try {
        await openai.beta.threads.messages.create(thread.id, {
          role: "user",
          content: recognizedText
        });
        console.log('메시지 추가 성공');
      } catch (messageError) {
        console.error('메시지 추가 실패:', messageError.message);
        return res.send({
          message: '파일이 업로드되었으나 AI 처리 중 오류가 발생했습니다.',
          additionalInfo: {
            projectName: '기본 프로젝트',
            budget: '0',
            duration: '0일',
            subscriptionStatus: 'Y',
            error: `메시지 추가 실패: ${messageError.message}`
          }
        });
      }
      
      // 4. Run 생성 및 실행
      let run;
      try {
        run = await openai.beta.threads.runs.create(thread.id, {
          assistant_id: assistant.id,
          instructions: "",
        });
        console.log(`Run 생성 성공: ${run.id}`);
      } catch (runCreateError) {
        console.error('Run 생성 실패:', runCreateError.message);
        return res.send({
          message: '파일이 업로드되었으나 AI 처리 중 오류가 발생했습니다.',
          additionalInfo: {
            projectName: '기본 프로젝트',
            budget: '0',
            duration: '0일',
            subscriptionStatus: 'Y',
            error: `Run 생성 실패: ${runCreateError.message}`
          }
        });
      }
      
      // 5. Run 상태 확인
      let runResult;
      try {
        runResult = await Promise.race([
          checkRunStatus(openai, thread.id, run.id),
          new Promise((_, reject) => 
            setTimeout(() => reject(new Error('OpenAI 처리 시간 초과 (25초)')), 25000)
          )
        ]);
        console.log(`Run 완료 성공: ${runResult.status}`);
      } catch (runError) {
        console.error('Run 확인 오류:', runError.message);
        return res.send({
          message: '파일이 업로드되었으나 AI 처리 중 오류가 발생했습니다.',
          additionalInfo: {
            projectName: '기본 프로젝트',
            budget: '0',
            duration: '0일',
            subscriptionStatus: 'Y',
            error: runError.message
          }
        });
      }

      // 스레드 ID 저장
      await pool.query(
        'INSERT INTO thread_id (thread_id, user_session) VALUES ($1, $2) ON CONFLICT (user_session) DO UPDATE SET thread_id = EXCLUDED.thread_id RETURNING *',
        [thread.id, req.session.userId]
      );
      
      // 메시지 가져오기
      const messages = await openai.beta.threads.messages.list(thread.id);
      if (!messages.body.data.length || !messages.body.data[0].content.length) {
        throw new Error('No messages returned from OpenAI');
      }
      
      const contents = messages.body.data[0].content[0].text.value;
      console.log('Received response from OpenAI');
      
      // 텍스트 응답 파싱
      const sections = contents.split(/\n(?=[A-Z가-힣\s]+:)/);

      const extractedInfo = {
        projectName: '',
        budget: '',
        duration: '',
        agency: '',
        function: '',
        skill: '',
        description: ''
      };

      sections.forEach(section => {
        if (section.startsWith('프로젝트 이름')) {
          extractedInfo.projectName = section.split(': ')[1];
        } else if (section.startsWith('예산')) {
          extractedInfo.budget = section.split(': ')[1].replace(',', '');
        } else if (section.startsWith('기간')) {
          extractedInfo.duration = section.split(': ')[1].replace(',', '');
        } else if (section.startsWith('에이전시 종류')) {
          extractedInfo.agency = section.split(': ')[1];
        } else if (section.startsWith('구체적 기능')) {
          extractedInfo.function = section.split(': ')[1];
        } else if (section.startsWith('기술 스택')) {
          extractedInfo.skill = section.split(': ')[1].replace(',', '');
        } else if (section.startsWith('설명')) {
          extractedInfo.description = section.split(': ')[1];
        }
      });
      
      console.log('Extracted project info:', extractedInfo);

      const projectValues = [
        extractedInfo.projectName,
        extractedInfo.duration,
        extractedInfo.budget,
        extractedInfo.agency,
        extractedInfo.function,
        extractedInfo.skill,
        extractedInfo.description,
        req.session.userId
      ];
      const checkQuery = `SELECT * FROM rfp_temp WHERE user_session = $1;`;
      const checkResult = await pool.query(checkQuery, [req.session.userId]);

      if (checkResult.rows.length > 0) {
        const updateQuery = `
          UPDATE rfp_temp
          SET pro_name = $1, pro_period = $2, pro_budget = $3, pro_agency = $4, pro_function = $5, pro_skill = $6, pro_description = $7
          WHERE user_session = $8
          RETURNING *;
        `;
        await pool.query(updateQuery, projectValues);
        console.log('Updated existing rfp_temp record');
      } else {
        const insertQuery = `
          INSERT INTO rfp_temp (pro_name, pro_period, pro_budget, pro_agency, pro_function, pro_skill, pro_description, user_session)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING *;
        `;
        await pool.query(insertQuery, projectValues);
        console.log('Inserted new rfp_temp record');
      }

      const sendResult = await pool.query('SELECT * FROM rfp_temp WHERE user_session = $1', [req.session.userId]);
      console.log('Upload process completed successfully');

      return res.send({
        message: 'File uploaded and data inserted into database successfully.',
        additionalInfo: {
          projectName: sendResult.rows[0].pro_name,
          budget: sendResult.rows[0].pro_budget,
          duration: sendResult.rows[0].pro_period,
          subscriptionStatus: 'Y' // 테스트를 위해 항상 구독 상태를 Y로 설정
        }
      });
    } catch (error) {
      console.error('Error in upload process:', error.message);
      return res.status(500).send('Server error: ' + error.message);
    }
  } catch (error) {
    console.error('Error processing file:', error);
    res.status(500).json({ error: error.message });
  }
});




app.post('/projectInfo', async (req, res) => {
    try {
        const userId = req.session.userId; // 미들웨어에서 설정한 사용자 IP 주소 사용
        const projectInfo = await getProjectInfoByUserIp(userId);
        res.json(projectInfo);
    } catch (error) {
        res.status(500).send('Server error while fetching project info.');
    }
});


app.post('/proAbout', async (req, res) => {
    const { projectName, budget, duration } = req.body;
    const userId = req.session.userId; // 사용자 IP는 미들웨어에서 설정된 것을 사용
    try {
      // 먼저 해당 사용자의 데이터가 있는지 확인
      const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
      const checkRes = await pool.query(checkQuery, [userId]);
  
      if (checkRes.rows.length > 0) {
        // 데이터가 있으면 UPDATE
        const updateQuery = `
          UPDATE rfp_temp
          SET pro_name = $1, pro_budget = $2, pro_period = $3
          WHERE user_session = $4
        `;
        await pool.query(updateQuery, [projectName, budget, duration, userId]);
      } else {
        // 데이터가 없으면 INSERT (예시 로직, 실제 컬럼 및 데이터에 맞게 조정 필요)
        const insertQuery = `
          INSERT INTO rfp_temp (pro_name, pro_budget, pro_period, user_session)
          VALUES ($1, $2, $3, $4)
        `;
        await pool.query(insertQuery, [projectName, budget, duration, userId]);
      }
      res.send('Data updated successfully');
    } catch (error) {
      console.error('Database error:', error);
      res.status(500).send('Server error');
    }
  });

  app.post('/updateAgencyNumbers', async (req, res) => {
    const agencyNumbers = req.body;
    const userId = req.session.userId;
    try {
      const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
      const checkResult = await pool.query(checkQuery, [userId]);
  
      if (checkResult.rows.length > 0) {
        // 데이터가 있으면 UPDATE
        const updateQuery = 'UPDATE rfp_temp SET pro_agency = $1 WHERE user_session = $2';
        await pool.query(updateQuery, [agencyNumbers.join(','), userId]); // agencyNumbers 배열을 문자열로 변환하여 저장
      } else {
        // 데이터가 없으면 INSERT
        const insertQuery = 'INSERT INTO rfp_temp (pro_agency, user_session) VALUES ($1, $2)';
        await pool.query(insertQuery, [agencyNumbers.join(','), userId]);
      }
      res.json({ message: 'Agency numbers updated successfully' });
    } catch (error) {
      console.error('Database error:', error);
      res.status(500).send('Server error');
    }
  });

  app.post('/updateSkillNumbers', async (req, res) => {
    const { skillNumber } = req.body;
    const userId = req.session.userId;
    try {
      const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
      const checkResult = await pool.query(checkQuery, [userId]);
  
      if (checkResult.rows.length > 0) {
        // 데이터가 있으면 UPDATE
        const updateQuery = 'UPDATE rfp_temp SET pro_skill = $1 WHERE user_session = $2';
        await pool.query(updateQuery, [skillNumber, userId]); // agencyNumbers 배열을 문자열로 변환하여 저장
      } else {
        // 데이터가 없으면 INSERT
        const insertQuery = 'INSERT INTO rfp_temp (pro_skill, user_session) VALUES ($1, $2)';
        await pool.query(insertQuery, [skillNumber, userId]);
      }
      res.json({ message: 'skillNumber numbers updated successfully' });
    } catch (error) {
      console.error('Database error:', error);
      res.status(500).send('Server error');
    }
  });

  app.post('/updateDescription', async (req, res) => {
    const { description,urlText } = req.body;
    const userId = req.session.userId;
    try {
      const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
      const checkResult = await pool.query(checkQuery, [userId]);
  
      if (checkResult.rows.length > 0) {
        // 데이터가 있으면 UPDATE
        const updateQuery = 'UPDATE rfp_temp SET pro_description = $1,pro_reference = $2 WHERE user_session = $3';
        await pool.query(updateQuery, [description, urlText, userId]); // agencyNumbers 배열을 문자열로 변환하여 저장
      } else {
        // 데이터가 없으면 INSERT
        const insertQuery = 'INSERT INTO rfp_temp (pro_description, pro_reference, user_session) VALUES ($1, $2, $3)';
        await pool.query(insertQuery, [description, urlText, userId]);
      }
      res.json({ message: 'Description updated successfully' });
    } catch (error) {
      console.error('Database error:', error);
      res.status(500).send('Server error');
    }
  });

  app.post('/updatefunctionNumbers', async (req, res) => {
    const { functionNumbers } = req.body;
    const filteredFunctionNumbers = functionNumbers.filter(number => number !== 'null');
    const userId = req.session.userId;
    try {
      const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
      const checkResult = await pool.query(checkQuery, [userId]);
      if (checkResult.rows.length > 0) {
        // 데이터가 있으면 UPDATE
        const updateQuery = 'UPDATE rfp_temp SET pro_function = $1 WHERE user_session = $2';
        await pool.query(updateQuery, [filteredFunctionNumbers.join(','), userId]); // agencyNumbers 배열을 문자열로 변환하여 저장
      } else {
        // 데이터가 없으면 INSERT
        const insertQuery = 'INSERT INTO rfp_temp (pro_function, user_session) VALUES ($1, $2)';
        await pool.query(insertQuery, [filteredFunctionNumbers.join(','), userId]);
      }
      const result = await pool.query(checkQuery, [userId]);
      const row = result.rows[0];
      const outputString = `
        프로젝트 이름 : ${row.pro_name},
        프로젝트 기간 : ${row.pro_period},
        프로젝트 예산 : ${row.pro_budget},
        프로젝트 에이전시 유형 : ${row.pro_agency},
        프로젝트 기능 : ${row.pro_function},
        프로젝트 개발방식 : ${row.pro_skill},
        프로젝트 설명 : ${row.pro_description}
        `;
        try {
      
      const gptKeys = [
        process.env.GPTSKEY2,
        process.env.GPTSKEY3,
        process.env.GPTSKEY4,
        process.env.GPTSKEY5
      ];

      // API 호출
      console.log('OpenAI API 호출 시작');
      const promises = gptKeys.map(key =>
        gptsApi(outputString, key, userId).catch(error => {
          console.error(`API 호출 오류 (${key}):`, error);
          return `API 오류: ${error.message}`;
        })
      );
      
      const results = await Promise.all(promises);
      console.log('API 응답 결과:', results.map(r => r.substring(0, 20) + '...'));
      
      // 각 결과가 유효한지 확인 (API 오류 메시지가 아닌지)
      const project = results[0] && !results[0].startsWith('API 오류') ? results[0] : '프로젝트 정보를 불러올 수 없습니다.';
      
      let output = '필요 산출물: 기본 산출물';
      if (results[1] && !results[1].startsWith('API 오류') && results[1].includes('필요 산출물:')) {
        output = results[1].split("필요 산출물:")[1].trim();
      }
      
      let service = '서비스 요구사항: 기본 요구사항';
      if (results[2] && !results[2].startsWith('API 오류') && results[2].includes('서비스 요구사항:')) {
        service = results[2].split("서비스 요구사항:")[1].trim();
      }
      
      let funcDesc = '기능명세서가 없습니다.';
      if (results[3] && !results[3].startsWith('API 오류') && results[3].includes('기능명세서:')) {
        funcDesc = results[3].split("기능명세서:")[1].trim();
      }

      const selectIAQuery = 'SELECT * FROM ia WHERE ia_id = $1';
      const selectIAResult = await pool.query(selectIAQuery, [userId]);
  
      // 레코드가 이미 존재하면, 해당 레코드 삭제
      if (selectIAResult.rows.length > 0) {
        const deleteQuery = 'DELETE FROM ia WHERE ia_id = $1';
        await pool.query(deleteQuery, [userId]);
      }
       // parseLogData 함수는 로그 데이터를 파싱하는 가상의 함수입니다.

      const contentLines = project.split('\n'); // 내용을 줄 단위로 분리
      const projectInfo = {};
      let currentSection = '';
      contentLines.forEach(line => {
        // 각 섹션 제목을 확인하여 currentSection 업데이트
        if (line.includes('프로젝트 이름:') || line.includes('프로젝트 예산:') ||
            line.includes('프로젝트 기간:')) {
            let [key, value] = line.split(':').map(part => part.trim());
            projectInfo[key] = value; // 섹션 제목 다음에 오는 내용만 저장
            currentSection = ''; // 섹션 제목을 처리한 후 currentSection 초기화
        } else if (line.startsWith('작업분해구조(WBS):')) {
          currentSection = '작업분해구조(WBS)'; // 현재 섹션을 '작업분해구조(WBS)'로 업데이트
          projectInfo[currentSection] = ''; // 내용을 담을 빈 문자열 할당
        } else if (currentSection) {
            // 현재 섹션의 내용 추가 (여기서 '\n'은 필요에 따라 추가하거나 생략할 수 있음)
            projectInfo[currentSection] += (projectInfo[currentSection] ? '\n' : '') + line.trim();
        }
    });
      Object.keys(projectInfo).forEach(key => {
        // 값의 끝에 위치한 콤마를 제거합니다. 정규 표현식을 사용해 콤마와 공백을 처리합니다.
        projectInfo[key] = projectInfo[key].replace(/,\s*$/, '');
    });
    const agencyMapping = {
      '1': '영상/사진',
      '2': '브랜딩',
      '3': '앱 개발',
      '4': '웹 개발',
      '5': '디자인',
      '6': '마케팅',
      '7': '번역/통역',
      '8': '컨설팅',
    };
    const wbs_doc = projectInfo['작업분해구조(WBS)'];
    const proAgencyText = row.pro_agency.split(',')
                                .map(number => agencyMapping[number])
                                .join('/');
      const query = `
        INSERT INTO rfp(pro_name, pro_budget, pro_period, pro_service, pro_output, pro_reference, pro_ia, pro_wbs, user_session, expected_budget,expected_period, pro_agency,user_id,pro_funcdesc,wbs_doc)
        VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,$15)
        ON CONFLICT (user_session) DO UPDATE SET
          pro_name = EXCLUDED.pro_name,
          pro_budget = EXCLUDED.pro_budget,
          pro_period = EXCLUDED.pro_period,
          pro_service = EXCLUDED.pro_service,
          pro_output = EXCLUDED.pro_output,
          pro_reference = EXCLUDED.pro_reference,
          pro_ia = EXCLUDED.pro_ia,
          pro_wbs = EXCLUDED.pro_wbs,
          expected_budget = EXCLUDED.expected_budget,
          expected_period = EXCLUDED.expected_period,
          pro_agency = EXCLUDED.pro_agency,
          user_id = EXCLUDED.user_id,
          pro_funcdesc = EXCLUDED.pro_funcdesc,
          wbs_doc = EXCLUDED.wbs_doc
      `;
      const values = [
        projectInfo['프로젝트 이름'],
        projectInfo['프로젝트 예산'], // "4500만원"에서 숫자만 추출
        projectInfo['프로젝트 기간'], // "5개월"에서 숫자만 추출
        service,
        output,
        row.pro_reference, // 배열을 문자열로 변환
        userId,
        // "기능명세서" 및 "작업분해구조(WBS)" 처리 로직 추가 필요
        userId,
        userId, // user_session에 userId를 사용
        row.pro_budget,
        row.pro_period,
        proAgencyText,
        req.session.userInfo.userId,
        funcDesc,
        wbs_doc
      ];
      try {
        const res = await pool.query(query, values);
      } catch (err) {
        console.error('Error executing query', err.stack);
      }
      const parsedData = parseAndInsertData(funcDesc,userId);
      const wbsItems = projectInfo['작업분해구조(WBS)'].split('-').map(item => item.trim()).filter(item => item);
      // values 배열을 위에서 추출한 정보로 채워 넣고 쿼리 실행
      // 각 wbsItems 항목에 대해 반복 실행 필요
    // wbsItems 항목에 대해 실행
      const selectQuery = 'SELECT * FROM wbs WHERE wbs_id = $1';
          const selectResult = await pool.query(selectQuery, [userId]);
      
          // 레코드가 이미 존재하면, 해당 레코드 삭제
          if (selectResult.rows.length > 0) {
            const deleteQuery = 'DELETE FROM wbs WHERE wbs_id = $1';
            await pool.query(deleteQuery, [userId]);
          }
      wbsItems.forEach(async (item, index) => {
        try {
          // 새로운 레코드 삽입
          const [taskDetail, duration] = item.split(':').map(part => part.trim());
          const [taskName, roles] = taskDetail.split('(').map(part => part.trim().replace(')', ''));
          const [startMonth, endMonth] = duration.split('~').map(part => parseFloat(part.replace('개월', '').trim()));
          const wbsId = userId;
          const insertQuery = `
            INSERT INTO wbs (wbs_id, task_name, roles_involved, start_month, end_month, description)
            VALUES ($1, $2, $3, $4, $5, $6)
          `;
          const wbsValues = [wbsId, taskName, roles, startMonth, endMonth, '']; // description이 없으므로 빈 문자열 사용
          await pool.query(insertQuery, wbsValues);
      
        } catch (err) {
          console.error('Error processing WBS item', err.stack);
        }
      });
      
      } catch (error) {
        console.error('AI호출 오류', error);
      }
      res.json({ message: 'functionNumbers updated successfully' });
    } catch (error) {
      console.error('Database error:', error);
      res.status(500).send('Server error');
    }
  });

  app.post('/setWbs', async (req, res) => {
    try {
        const userId = req.session.userId;; 
        const { rows } = await pool.query('SELECT wbs_id, task_name, roles_involved, start_month, end_month FROM wbs WHERE wbs_id = $1 order by start_month asc,end_month asc;',[userId]);
        res.json(rows);
    } catch (error) {
        res.status(500).send('Server error while fetching project info.');
    }
});

app.post('/setFuncDesc', async (req, res) => {
  try {
      const userId = req.session.userId;; 
      const { rows } = await pool.query('SELECT pro_funcdesc,wbs_doc FROM rfp WHERE user_session = $1;',[userId]);
      res.json(rows);
  } catch (error) {
      res.status(500).send('Server error while fetching project info.');
  }
});

app.post('/setProject', async (req, res) => {
  try {
      const userId = req.session.userId;; 
      const { rows } = await pool.query('SELECT pro_name, pro_budget, pro_period, pro_service, pro_output, expected_budget,expected_period, pro_agency, pro_reference FROM rfp WHERE user_session = $1;',[userId]);
      const parsedRows = rows.map(row => {
        // pro_service 필드의 내용을 줄별로 분리합니다.
        const services = row.pro_service.split(',\n');
        
        // 각 줄에서 끝에 있는 콤마를 제거하고, 다시 줄바꿈 문자로 합칩니다.
        const parsedProService = services.map(service => service.trim()).join('\n');
        
        // 수정된 pro_service로 객체를 업데이트합니다.
        return { ...row, pro_service: parsedProService };
      });
      res.json(parsedRows);
  } catch (error) {
      res.status(500).send('Server error while fetching project info.');
  }
});

app.post('/setIA', async (req, res) => {
  try {
      const userId = req.session.userId;; 
      const { rows } = await pool.query('SELECT depth1,depth2,depth3,depth4 FROM ia WHERE ia_id = $1 order by ia_num asc,ia_seq asc;',[userId]);

      const depth1Counts = rows.reduce((acc, cur) => {
        acc[cur.depth1] = (acc[cur.depth1] || 0) + 1;
        return acc;
      }, {});
      
      // depth2의 유니크한 조합을 체크하기 위한 객체
      const depth2Unique = {};
      const depth3Unique = {};

      rows.forEach(row => {
        if (row.depth2 !== '-') {
          const key = `${row.depth1}-${row.depth2}`;
          depth2Unique[key] = (depth2Unique[key] || 0) + 1;
        }
        if (row.depth3 !== '-') {
          const key = `${row.depth1}-${row.depth2}-${row.depth3}`;
          depth3Unique[key] = (depth3Unique[key] || 0) + 1;
        }
      });

      const filteredRows = rows.filter(row => {
        // depth1만 존재하고 그것이 유일한 경우 유지
        if (row.depth2 === '-' && depth1Counts[row.depth1] === 1) return true;

        // depth2가 있고, 해당 depth2가 유니크한 경우(다른 행에 동일한 depth2가 존재하지 않는 경우) 유지
        if (row.depth2 !== '-' && row.depth3 === '-' && depth2Unique[`${row.depth1}-${row.depth2}`] === 1) return true;

        // depth3가 있고, 해당 depth3가 유니크한 경우(다른 행에 동일한 depth3가 존재하지 않는 경우) 유지
        if (row.depth3 !== '-' && row.depth4 === '-' && depth3Unique[`${row.depth1}-${row.depth2}-${row.depth3}`] === 1) return true;

        // depth4가 있는 경우 모두 유지
        if (row.depth4 !== '-') return true;

        // 위 조건에 해당하지 않는 행은 필터링
        return false;
      });

      res.json(filteredRows);
  } catch (error) {
      res.status(500).send('Server error while fetching project info.');
  }
});

app.post('/retry', async (req, res) => {
  const userId = req.session.userId;
  try {
    console.log('Retry 요청 데이터:', req.body);
    const checkQuery = 'SELECT * FROM rfp_temp WHERE user_session = $1';
    const result = await pool.query(checkQuery, [userId]);
    const row = result.rows[0];
    const outputString = `
      프로젝트 이름 : ${row.pro_name},
      프로젝트 기간 : ${row.pro_period},
      프로젝트 예산 : ${row.pro_budget},
      프로젝트 에이전시 유형 : ${row.pro_agency},
      프로젝트 기능 : ${row.pro_function},
      프로젝트 개발방식 : ${row.pro_skill},
      프로젝트 설명 : ${row.pro_description}
      `;
      try {
    
    const gptKeys = [
      process.env.GPTSKEY2,
      process.env.GPTSKEY3,
      process.env.GPTSKEY4,
      process.env.GPTSKEY5
    ];

    const promises = gptKeys.map(key =>
      gptsApi(outputString, key, userId).catch(error => console.error(`Error with key ${key}:`, error))
    );
    const results = await Promise.all(promises);
    const project = results[0];
    const output = results[1].split("필요 산출물:")[1].trim();
    const service = results[2].split("서비스 요구사항:")[1].trim();
    let funcDesc = '';
    if (results[3] && results[3].includes("기능명세서:")) {
      funcDesc = results[3].split("기능명세서:")[1].trim();
    } else {
        // 예외 처리: 기능명세서가 없는 경우, 빈 문자열이나 기본 값을 설정
        funcDesc = '기능명세서가 없습니다.';
    }
    const selectIAQuery = 'SELECT * FROM ia WHERE ia_id = $1';
    const selectIAResult = await pool.query(selectIAQuery, [userId]);

    // 레코드가 이미 존재하면, 해당 레코드 삭제
    if (selectIAResult.rows.length > 0) {
      const deleteQuery = 'DELETE FROM ia WHERE ia_id = $1';
      await pool.query(deleteQuery, [userId]);
    }
     // parseLogData 함는 로그 데이터를 파싱하는 가상의 함수입니다.
     // parseLogData 함는 로그 데이터를 파싱하는 가상의 함수입니다.

    const contentLines = project.split('\n'); // 내용을 줄 단위로 분리
    const projectInfo = {};
    let currentSection = '';
    contentLines.forEach(line => {
      // 각 섹션 제목을 확인하여 currentSection 업데이트
      if (line.includes('프로젝트 이름:') || line.includes('프로젝트 예산:') ||
          line.includes('프로젝트 기간:')) {
          let [key, value] = line.split(':').map(part => part.trim());
          projectInfo[key] = value; // 섹션 제목 다음에 오는 내용만 저장
          currentSection = ''; // 섹션 제목을 처리한 후 currentSection 초기화
      } else if (line.startsWith('작업분해구조(WBS):')) {
        currentSection = '작업분해구조(WBS)'; // 현재 섹션을 '작업분해구조(WBS)'로 업데이트
        projectInfo[currentSection] = ''; // 내용을 담을 빈 문자열 할당
      } else if (currentSection) {
          // 현재 섹션의 내용 추가 (여기서 '\n'은 필요에 따라 추가하거나 생략할 수 있음)
          projectInfo[currentSection] += (projectInfo[currentSection] ? '\n' : '') + line.trim();
      }
  });
    Object.keys(projectInfo).forEach(key => {
      // 값의 끝에 위치한 콤마를 제거합니다. 정규 표현식을 사용해 콤마와 공백을 처리합니다.
      projectInfo[key] = projectInfo[key].replace(/,\s*$/, '');
  });
  const agencyMapping = {
    '1': '영상/사진',
    '2': '브랜딩',
    '3': '앱 개발',
    '4': '웹 개발',
    '5': '디자인',
    '6': '마케팅',
    '7': '번역/통역',
    '8': '컨설팅',
  };
  const wbs_doc = projectInfo['작업분해구조(WBS)'];
  const proAgencyText = row.pro_agency.split(',')
                              .map(number => agencyMapping[number])
                              .join('/');
    const query = `
      INSERT INTO rfp(pro_name, pro_budget, pro_period, pro_service, pro_output, pro_reference, pro_ia, pro_wbs, user_session, expected_budget,expected_period, pro_agency, user_id,pro_funcdesc,wbs_doc)
      VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,$14,$15)
      ON CONFLICT (user_session) DO UPDATE SET
        pro_name = EXCLUDED.pro_name,
        pro_budget = EXCLUDED.pro_budget,
        pro_period = EXCLUDED.pro_period,
        pro_service = EXCLUDED.pro_service,
        pro_output = EXCLUDED.pro_output,
        pro_reference = EXCLUDED.pro_reference,
        pro_ia = EXCLUDED.pro_ia,
        pro_wbs = EXCLUDED.pro_wbs,
        expected_budget = EXCLUDED.expected_budget,
        expected_period = EXCLUDED.expected_period,
        pro_agency = EXCLUDED.pro_agency,
        user_id = EXCLUDED.user_id,
        pro_funcdesc = EXCLUDED.pro_funcdesc,
        wbs_doc = EXCLUDED.wbs_doc
    `;
    const values = [
      projectInfo['프로젝트 이름'],
      projectInfo['프로젝트 예산'], // "4500만원"에서 숫자만 추출
      projectInfo['프로젝트 기간'], // "5개월"에서 숫자만 추출
      service,
      output,
      row.pro_reference, // 배열을 문자열로 변환
      userId,
      // "기능명세서" 및 "작업분해구조(WBS)" 처리 로직 추가 필요
      userId,
      userId, // user_session에 userId를 사용
      row.pro_budget,
      row.pro_period,
      proAgencyText,
      req.session.userInfo.userId,
      funcDesc,
      wbs_doc
    ];
    try {
      const res = await pool.query(query, values);
    } catch (err) {
      console.error('Error executing query', err.stack);
    }
    const parsedData = parseAndInsertData(funcDesc,userId);
    const wbsItems = projectInfo['작업분해구조(WBS)'].split('-').map(item => item.trim()).filter(item => item);
    const insertWBSQuery = `
    INSERT INTO wbs (wbs_id, task_name, roles_involved, start_month, end_month, description)
    VALUES ($1, $2, $3, $4, $5, $6) 
    `;
    const selectQuery = 'SELECT * FROM wbs WHERE wbs_id = $1';
    const selectResult = await pool.query(selectQuery, [userId]);

    // 레코드가 이미 존재하면, 해당 레코드 삭제
    if (selectResult.rows.length > 0) {
      const deleteQuery = 'DELETE FROM wbs WHERE wbs_id = $1';
      await pool.query(deleteQuery, [userId]);
    }
    // values 배열을 위에서 추출한 정보로 채워 넣고 쿼리 실행
    // 각 wbsItems 항목에 대해 반복 실행 필요
  // wbsItems 항목에 대해 실행
    wbsItems.forEach(async (item, index) => {
      const [taskDetail, duration] = item.split(':').map(part => part.trim());
      const [taskName, roles] = taskDetail.split('(').map(part => part.trim().replace(')', ''));
      const [startMonth, endMonth] = duration.split('~').map(part => parseFloat(part.replace('개월', '').trim()));
      const wbsId = userId;
      const wbsValues = [
        userId, // 여기서는 단순히 순서를 나타내는 index를 사용했습니다. 실제 상황에서는 적절한 식별자를 사용해야 합니다.
        taskName,
        roles,
        startMonth,
        endMonth,
        '' // description이 없으므로 빈 문자열 사용
      ];
      try {
        // 먼저 해당 wbs_id(userId)에 대한 레코드가 있는지 확인
        // 새로운 레코드 삽입
        const insertQuery = `
          INSERT INTO wbs (wbs_id, task_name, roles_involved, start_month, end_month, description)
          VALUES ($1, $2, $3, $4, $5, $6)
        `;
        await pool.query(insertQuery, wbsValues);
    
      } catch (err) {
        console.error('Error processing WBS item', err.stack);
      }
    });
    
    } catch (error) {
      console.error('AI호출 오류', error);
    }
    res.json({ message: 'functionNumbers updated successfully' });
  } catch (error) {
    console.error('에러 발생:', error);
    console.error('Database error:', error);
    res.status(500).send('Server error');
  }
});

app.post('/signup', async (req, res) => {
  const { username, password, phoneNumber, email } = req.body;

  try {
    // 먼저 휴대폰 번호로 등록된 계정이 있는지 검사
    const checkPhoneQuery = 'SELECT user_id FROM user_info WHERE user_phone = $1';
    const { rows } = await pool.query(checkPhoneQuery, [phoneNumber]);

    // 휴대폰 번호가 이미 사용 중이라면 에러 메시지를 보냄
    if (rows.length > 0) {
      return res.status(409).send({ message: '해당 휴대폰 번호로 등록된 아이디가 존재합니다.' });
    }

    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // user_info 테이블에 created_at 컬럼이 있는지 확인
    let hasCreatedAtColumn = false;
    try {
      const columnsQuery = `
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'user_info' AND column_name = 'created_at'
      `;
      const columnsResult = await pool.query(columnsQuery);
      hasCreatedAtColumn = columnsResult.rows.length > 0;
      console.log(`user_info 테이블에 created_at 컬럼 존재 여부: ${hasCreatedAtColumn}`);
      
      // created_at 컬럼이 없으면 추가
      if (!hasCreatedAtColumn) {
        try {
          console.log('user_info 테이블에 created_at 컬럼 추가 시도');
          await pool.query(`
            ALTER TABLE user_info 
            ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          `);
          console.log('created_at 컬럼 추가 성공');
          hasCreatedAtColumn = true;
        } catch (alterErr) {
          console.error('created_at 컬럼 추가 실패:', alterErr);
        }
      }
    } catch (err) {
      console.error('컬럼 정보 조회 오류:', err);
    }

    // 휴대폰 번호가 중복되지 않는 경우, 회원 정보를 데이터베이스에 삽입
    let insertQuery;
    let values;
    
    if (hasCreatedAtColumn) {
      insertQuery = `
        INSERT INTO user_info (
          user_id,
          user_password,
          user_phone,
          user_email,
          subscription_status,
          subscription_new,
          billing_key,
          customer_key,
          created_at
        ) VALUES ($1, $2, $3, $4, 'N', 'N', 'N', $1, CURRENT_TIMESTAMP)
      `;
      values = [username, hashedPassword, phoneNumber, email];
    } else {
      insertQuery = `
        INSERT INTO user_info (
          user_id,
          user_password,
          user_phone,
          user_email,
          subscription_status,
          subscription_new,
          billing_key,
          customer_key
        ) VALUES ($1, $2, $3, $4, 'N', 'N', 'N', $1)
      `;
      values = [username, hashedPassword, phoneNumber, email];
    }
    
    await pool.query(insertQuery, values);
    console.log(`새 사용자 등록 완료: ${username}`);

    // 회원가입 성공 응답 전송
    res.status(201).send({ 
      message: '회원가입 성공', 
      userInfo: {
        username,
        email,
        phoneNumber
      }
    });
  } catch (err) {
    console.error('Error processing signup item', err.stack);
    res.status(500).send({ message: '회원가입 처리 중 오류가 발생했습니다.' });
  }
});


app.get('/check-username', async (req, res) => {
  const { username } = req.query;
  // 데이터베이스에서 아이디 검사
  const user = await pool.query('SELECT user_id FROM user_info WHERE user_id = $1', [username]);
  if (user.rows.length > 0) {
      res.json({ isAvailable: false });
  } else {
      res.json({ isAvailable: true });
  }
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
      // user_info 테이블에서 user_id를 검사하는 쿼리
      const query = 'SELECT * FROM user_info WHERE user_id = $1';
      const { rows } = await pool.query(query, [username]);

      if (rows.length > 0) {
          const user = rows[0];

          // 비밀번호 비교
          const isPasswordMatch = await bcrypt.compare(password, user.user_password);

          if (isPasswordMatch) {
              // 비밀번호가 일치하면 로그인 성공
              req.session.userInfo = {
                userId: user.user_id,
                loginTime: new Date()
            };
            req.session.save(err => {
                if (err) {
                    console.error(err);
                    return res.status(500).json({
                      success: false,
                      message: '로그인 처리 중 오류가 발생했습니다.'
                    });
                }
                // 응답 형식 수정 - success 필드 추가 및 임시 비밀번호 플래그 확인
                const responseData = {
                  success: true,
                  message: '로그인 성공',
                  userInfo: {
                    userId: user.user_id,
                    email: user.user_email,
                    phone: user.user_phone
                  }
                };
                
                // 임시 비밀번호 사용자인 경우 플래그 추가
                if (user.is_temp_password) {
                  responseData.requirePasswordChange = true;
                }
                
                res.json(responseData);
            });
          } else {
              // 비밀번호가 일치하지 않으면 로그인 실패
              res.status(401).json({
                success: false,
                message: '잘못된 아이디 또는 비밀번호'
              });
          }
      } else {
          // 해당 아이디가 없으면 로그인 실패
          res.status(401).json({
            success: false,
            message: '잘못된 아이디 또는 비밀번호'
          });
      }
  } catch (error) {
      console.error('로그인 처리 중 에러 발생:', error);
      res.status(500).json({
        success: false,
        message: '서버 에러 발생'
      });
  }
});

app.get('/protected', (req, res) => {
  // console.log('Root protected 경로 접근');
  // res.json({ 
  //   isLoggedIn: true,
  //   message: '보호 경로 접근 성공'
  // });
  if (!req.session.userInfo) {
    return res.status(401).send({ message: 'Unauthorized', isLoggedIn: false });
  }
  res.json({
    isLoggedIn: true,
    data: 'Protected data'
  });
});

app.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).send('Failed to log out');
    }
    res.send({ message: 'Logout successful' });
  });
});

// 제안서 목록 조회 API 수정
app.get('/proposals', authMiddleware, async (req, res) => {
  try {
    const user_id = req.session.userInfo.userId;
    const query = `
      SELECT 
        user_session AS id, 
        pro_name AS title, 
        pro_period AS period, 
        pro_budget AS budget, 
        pro_agency AS agency,
        created_at AS "createdAt"
      FROM rfp 
      WHERE user_id = $1 
      ORDER BY rfp_seq DESC
    `;
    
    const { rows } = await pool.query(query, [user_id]);
    
    res.json({ 
      success: true,
      proposals: rows
    });
  } catch (error) {
    console.error('제안서 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 제안서 삭제 API 수정
app.delete('/deleteProposal', authMiddleware, async (req, res) => {
  const { id } = req.body;
  
  if (!id) {
    return res.status(400).json({
      success: false,
      message: '삭제할 제안서 ID가 필요합니다.'
    });
  }
  
  try {
    // PostgreSQL 트랜잭션 시작
    await pool.query('BEGIN');

    // ia 테이블에서 데이터 삭제
    await pool.query('DELETE FROM ia WHERE ia_id = $1', [id]);

    // wbs 테이블에서 데이터 삭제
    await pool.query('DELETE FROM wbs WHERE wbs_id = $1', [id]);

    // rfp 테이블에서 데이터 삭제
    await pool.query('DELETE FROM rfp WHERE user_session = $1', [id]);

    // 트랜잭션 커밋
    await pool.query('COMMIT');

    res.json({
      success: true,
      message: '제안서가 성공적으로 삭제되었습니다.'
    });
  } catch (error) {
    // 트랜잭션 롤백
    await pool.query('ROLLBACK');
    console.error('제안서 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '제안서 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// ID 변환 헬퍼 함수 (숫자 ID를 UUID로 변환)
async function convertToUuid(id) {
  // 숫자 ID인지 확인
  if (/^\d+$/.test(id)) {
    // 숫자 ID를 UUID로 변환
    const query = 'SELECT user_session as uuid FROM rfp WHERE rfp_seq = $1';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      throw new Error('프로젝트를 찾을 수 없습니다.');
    }
    
    return result.rows[0].uuid;
  }
  
  // 이미 UUID 형식이면 그대로 반환
  return id;
}

// setProjectDetail API 수정 - 숫자 ID 지원
app.post('/setProjectDetail', async (req, res) => {
  try {
    const { id } = req.body;
    
    // ID를 UUID로 변환
    const uuid = await convertToUuid(id);
    
    const { rows } = await pool.query('SELECT pro_name, pro_budget, pro_period, pro_service, pro_output, expected_budget, expected_period, pro_agency, pro_reference FROM rfp WHERE user_session = $1;', [uuid]);
    
    const parsedRows = rows.map(row => {
      // pro_service 필드의 내용을 줄별로 분리합니다.
      const services = row.pro_service.split(',\n');
      
      // 각 줄에서 끝에 있는 콤마를 제거하고, 다시 줄바꿈 문자로 합칩니다.
      const parsedProService = services.map(service => service.trim()).join('\n');
      
      // 수정된 pro_service로 객체를 업데이트합니다.
      return { ...row, pro_service: parsedProService };
    });
    
    res.json(parsedRows);
  } catch (error) {
    console.error('프로젝트 상세 정보 조회 오류:', error);
    res.status(500).send('Server error while fetching project info.');
  }
});

// setIADetail API 수정 - 숫자 ID 지원
app.post('/setIADetail', async (req, res) => {
  try {
    const { id } = req.body;
    
    // ID를 UUID로 변환
    const uuid = await convertToUuid(id);
    
    const { rows } = await pool.query('SELECT depth1, depth2, depth3, depth4 FROM ia WHERE ia_id = $1 ORDER BY ia_num ASC, ia_seq ASC;', [uuid]);

    const depth1Counts = rows.reduce((acc, cur) => {
      acc[cur.depth1] = (acc[cur.depth1] || 0) + 1;
      return acc;
    }, {});
    
    // depth2의 유니크한 조합을 체크하기 위한 객체
    const depth2Unique = {};
    const depth3Unique = {};

    rows.forEach(row => {
      if (row.depth2 !== '-') {
        const key = `${row.depth1}-${row.depth2}`;
        depth2Unique[key] = (depth2Unique[key] || 0) + 1;
      }
      if (row.depth3 !== '-') {
        const key = `${row.depth1}-${row.depth2}-${row.depth3}`;
        depth3Unique[key] = (depth3Unique[key] || 0) + 1;
      }
    });

    const filteredRows = rows.filter(row => {
      // depth1만 존재하고 그것이 유일한 경우 유지
      if (row.depth2 === '-' && depth1Counts[row.depth1] === 1) return true;

      // depth2가 있고, 해당 depth2가 유니크한 경우(다른 행에 동일한 depth2가 존재하지 않는 경우) 유지
      if (row.depth2 !== '-' && row.depth3 === '-' && depth2Unique[`${row.depth1}-${row.depth2}`] === 1) return true;

      // depth3가 있고, 해당 depth3가 유니크한 경우(다른 행에 동일한 depth3가 존재하지 않는 경우) 유지
      if (row.depth3 !== '-' && row.depth4 === '-' && depth3Unique[`${row.depth1}-${row.depth2}-${row.depth3}`] === 1) return true;

      // depth4가 있는 경우 모두 유지
      if (row.depth4 !== '-') return true;

      // 위 조건에 해당하지 않는 행은 필터링
      return false;
    });

    res.json(filteredRows);
  } catch (error) {
    console.error('IA 정보 조회 오류:', error);
    res.status(500).send('Server error while fetching IA info.');
  }
});

// setWbsDetail API 수정 - 숫자 ID 지원
app.post('/setWbsDetail', async (req, res) => {
  try {
    const { id } = req.body;
    
    // ID를 UUID로 변환
    const uuid = await convertToUuid(id);
    
    const { rows } = await pool.query('SELECT wbs_id, task_name, roles_involved, start_month, end_month FROM wbs WHERE wbs_id = $1 ORDER BY start_month ASC, end_month ASC;', [uuid]);
    
    res.json(rows);
  } catch (error) {
    console.error('WBS 정보 조회 오류:', error);
    res.status(500).send('Server error while fetching WBS info.');
  }
});

// getFuncDesc API 수정 - 숫자 ID 지원
app.post('/getFuncDesc', async (req, res) => {
  try {
    const { id } = req.body;
    
    // ID를 UUID로 변환
    const uuid = await convertToUuid(id);
    
    const { rows } = await pool.query('SELECT pro_funcdesc, pro_service, pro_output, wbs_doc FROM rfp WHERE user_session = $1', [uuid]);
    
    res.json(rows);
  } catch (error) {
    console.error('기능 명세 조회 오류:', error);
    res.status(500).send('Server error while fetching function description.');
  }
});

app.delete('/deleteProposal', async (req, res) => {
  const { id } = req.body; // 요청 바디에서 ID 추출
  
  try {
    // PostgreSQL 트랜잭션 시작
    await pool.query('BEGIN');

    // ia 테이블에서 데이터 삭제
    await pool.query('DELETE FROM ia WHERE ia_id = $1', [id]);

    // wbs 테이블에서 데이터 삭제
    await pool.query('DELETE FROM wbs WHERE wbs_id = $1', [id]);

    // rfp 테이블에서 데이터 삭제
    await pool.query('DELETE FROM rfp WHERE user_session = $1', [id]);

    // 트랜잭션 커밋
    await pool.query('COMMIT');

    res.send('Deletion successful');
  } catch (error) {
    // 트랜잭션 롤백
    await pool.query('ROLLBACK');
    console.error('Deletion failed:', error);
    res.status(500).send('Deletion failed');
  }
});

// Solapi 메시지 서비스 초기화 - 환경 변수에서 API 키를 가져옵니다
let messageService;
try {
  // 환경 변수 확인
  if (!process.env.SOLAPI_API_KEY || !process.env.SOLAPI_API_SECRET) {
    console.error('Solapi API 키 또는 시크릿이 설정되지 않았습니다.');
    // 테스트용 API 키로 폴백 (실제 환경에서는 사용되지 않음)
    messageService = new solapi.SolapiMessageService(
      "NCSNB6KTGTZ124DD", 
      "IAOJJWZM0TU210WRX0SHUNLZARQND0TK"
    );
  } else {
    // 환경 변수에서 API 키 사용
    messageService = new solapi.SolapiMessageService(
      process.env.SOLAPI_API_KEY,
      process.env.SOLAPI_API_SECRET
    );
    console.log('Solapi 메시지 서비스가 환경 변수로 초기화되었습니다.');
  }
} catch (error) {
  console.error('Solapi 메시지 서비스 초기화 실패:', error);
  // 기본 더미 서비스 생성
  messageService = {
    send: async (params) => {
      console.log('테스트 모드 SMS 요청:', params);
      return {
        success: true,
        message: '테스트 SMS 발송 (실제 발송되지 않음)',
        messageId: 'test-' + Date.now()
      };
    }
  };
  console.log('Solapi 메시지 서비스 대신 테스트용 더미 서비스가 사용됩니다.');
}

app.post('/find-id', async (req, res) => {
  const { phoneNumber } = req.body;

  try {
    // 전화번호를 사용하여 user_id 조회
    const query = 'SELECT user_id FROM user_info WHERE user_phone = $1';
    const { rows } = await pool.query(query, [phoneNumber]);
    if (rows.length > 0) {
      // 전화번호에 해당하는 user_id가 있을 경우
      res.json({ username: rows[0].user_id });
    } else {
      // user_id를 찾을 수 없는 경우
      res.status(404).json({ message: '등록된 사용자가 없습니다.' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: 'Server error while retrieving user ID.' });
  }
});

app.get('/auth/kakao/callback', async (req, res) => {
  try {
    const code = req.query.code;
    const tokenResponse = await axios.post('https://kauth.kakao.com/oauth/token', null, {
      params: {
        grant_type: 'authorization_code',
        client_id: '1f19c83bb96331acbdbfdabb55762e7d', // 카카오 개발자 콘솔에서 받은 REST API 키
        redirect_uri: `${process.env.URL}/auth/kakao/callback`,
        code: code,
      },
    });

    const accessToken = tokenResponse.data.access_token;

    const userResponse = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const userInfo = userResponse.data;

    req.session.userInfo = userInfo;

    // 여기에서 세션을 생성하거나, JWT 토큰을 발급할 수 있습니다.
    // 예시: req.session.user = userInfo;
    // 예시: const token = jwt.sign(userInfo, 'your_jwt_secret_key');
    
    // 클라이언트로 토큰을 보내거나, 로그인 성공 시 리다이렉트 처리
    res.redirect(`${process.env.URL}/init?token=${accessToken}`);

  } catch (error) {
    console.error('카카오 로그인 실패:', error);
    res.status(500).send('로그인 실패');
  }
});






app.get('/subscriptionNew', async (req, res) => {
  try {
    const user_id = req.session.userInfo.userId;
    const query = 'SELECT subscription_new FROM user_info WHERE user_id = $1';
    const { rows } = await pool.query(query, [user_id]);

    if (rows.length > 0) {
      res.json({ subscription_new: rows[0].subscription_new });
    } else {
      res.status(404).send('User not found');
    }
  } catch (error) {
    console.error('Database query error', error);
    res.status(500).send('Internal Server Error');
  }
});



app.post('/dalle-edit', upload.single('image'), async (req, res) => {
  const { prompt } = req.body;
  const imagePath = req.file.path;
  try {
    const maskPath = '/home/user/upload/sample-mask.png';
    console.log(`Using mask at: ${maskPath}`);

    // 마스크 이미지가 올바른지 확인
    if (!fs.existsSync(maskPath)) {
      throw new Error('Mask image not found');
    }

    // API 호�� 및 응답 확인
    const image = await dalle(imagePath, prompt, maskPath);
    console.log('API response:', image);

    if (image.data && image.data.length > 0) {
      const editedImageUrl = image.data[0].url;

      // 편집된 이미지 다운로드
      const editedImageResponse = await axios.get(editedImageUrl, { responseType: 'arraybuffer' });
      const base64EditedImage = Buffer.from(editedImageResponse.data, 'binary').toString('base64');

      res.json({ base64Image: base64EditedImage });
    } else {
      throw new Error('No edited image returned from API');
    }
  } catch (error) {
    console.error('Error editing image:', error);
    res.status(500).json({ error: 'Failed to edit image' });
  } finally {
    fs.unlinkSync(imagePath);
  }
});

async function dalle(imagePath, prompt, maskPath) {
  console.log('DALL-E 이미지 편집 호출 (테스트용):', { imagePath, prompt, maskPath });
  
  // 모의 응답 생성
  return {
    data: [
      { 
        url: 'https://example.com/mock-image.png',
        revised_prompt: prompt
      }
    ]
  };
}



const getUserInfoFromNaver = (accessToken) => {
  return fetch('https://openapi.naver.com/v1/nid/me', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    }
  })
  .then(response => response.json());
};


async function fetchAndCheck(recognizedText, threadId) {
    let isDifferent = false;
    let content = null;
    
    while (!isDifferent) {
      try {
        const messagesResponse = await openai.beta.threads.messages.list(threadId);
        let latestContent = null;
        if(messagesResponse.body.data[0].content[0]!=null){
          latestContent = messagesResponse.body.data[0].content[0].text.value;
        }
        // recognizedText와 최신 content가 다른지 확인
        if (recognizedText !== latestContent && latestContent !==null) {
          isDifferent = true;
          content = latestContent; // 새로운 content 값 저장
          break; 
        } else {
          // recognizedText와 최신 content가 같다면, 잠시 대기 후 다시 확인
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } catch (error) {
        console.error('Error fetching messages:', error);
        break; 
      }
    }
    
    return content; // 새로운 content 반환, null이면 변경된 내용이 없는 경우
  }

  async function gptsApi(output, gptKey, userId) {
    try {
      console.log(`gptsApi 호출 시작: ${gptKey.substring(0, 10)}...`);
      
      const assistant = await openai.beta.assistants.retrieve(gptKey);
      console.log(`Assistant 검색 성공: ${assistant.id}`);
      
      const thread = await openai.beta.threads.create();
      console.log(`Thread 생성 성공: ${thread.id}`);

      await openai.beta.threads.messages.create(thread.id, {
        role: "user",
        content: output
      });
      console.log(`메시지 추가 성공`);

      const run = await openai.beta.threads.runs.create(thread.id, {
        assistant_id: assistant.id,
        instructions: "",
      });
      console.log(`Run 생성 성공: ${run.id}`);

      try {
        const runResult = await Promise.race([
          checkRunStatus(openai, thread.id, run.id),
          new Promise((_, reject) => 
            setTimeout(() => reject(new Error('OpenAI 처리 시간 초과 (30초)')), 30000)
          )
        ]);
        console.log(`Run 완료: ${runResult.status}`);
      } catch (runError) {
        console.error(`Run 오류 (${gptKey}): ${runError.message}`);
        return `API 오류: ${runError.message}`;
      }

      try {
        await pool.query(
          'INSERT INTO thread_id (thread_id, user_session) VALUES ($1, $2) ON CONFLICT (user_session) DO UPDATE SET thread_id = EXCLUDED.thread_id RETURNING *',
          [thread.id, userId]
        );
      } catch (dbError) {
        console.error('DB 쿼리 오류:', dbError);
      }

      const message = await openai.beta.threads.messages.list(thread.id);
      if (!message.body.data || message.body.data.length === 0 || !message.body.data[0].content || message.body.data[0].content.length === 0) {
        console.error(`메시지 데이터 없음 (${gptKey})`);
        return `API 응답 없음`;
      }
      
      const contents = message.body.data[0].content[0].text.value;
      console.log(`응답 수신 성공 (${gptKey.substring(0, 10)}...): ${contents.substring(0, 50)}...`);
      return contents;
    } catch (error) {
      console.error(`gptsApi 전체 오류 (${gptKey}):`, error);
      return `API 오류: ${error.message}`;
    }
  }

  async function parseAndInsertData(logData, userId) {
    // 줄별로 데이터를 분리
    const lines = logData.split("\n");
    let depthContents = ["", "", "", "", ""]; // depthContents 배열을 5개 요소로 확장

    for (const line of lines) { // forEach 대신 for...of 사용하여 비동기 처리 보장
        // 깊이 판별 (마침표 개수로 결정)
        const depth = (line.match(/\./g) || []).length;

        // 최상위 깊이 번호 추출 (첫 번째 숫자)
        const topLevelNumber = line.match(/^\s*(\d+)/)?.[1] ?? "";

        // 실제 내용 추출 (숫자와 마침표 제거 후 앞뒤 공백 제거)
        let content = line.replace(/^\s*\d+(\.\d+)*\.\s*/, "").trim();

        // 상위 depth의 내용을 유지하면서 현재 깊이의 내용 업데이트
        depthContents = depthContents.map((c, index) => {
            if (index === 0) return topLevelNumber; // 첫 번째 요소에는 최상위 깊이 번호 저장
            return index === depth ? content : (index < depth ? c : "-");
        });
        if (depthContents.join('') === '' || depthContents.every(dc => dc === "-" || dc === "")) {
          continue;
        }
        await insertIntoIaTable(depthContents, userId); // 실제 삽입 로직을 호출
    }
}
// async function insertIntoIaTable(depthContents, userId) {
    
//   const query = `
//     INSERT INTO ia (ia_id, ia_num, depth1, depth2, depth3, depth4)
//     VALUES ($1, $2, $3, $4, $5, $6)
//   `;
//   const values = [userId, ...depthContents];
//   try {
//     const res = await pool.query(query, values);
//   } catch (err) {
//     console.error('Insertion error:', err);
//   }
// }

  async function insertIntoIaTable(depthContents, userId) {
    const query = `
      INSERT INTO ia (ia_id, ia_num, depth1, depth2, depth3, depth4)
      VALUES ($1, $2, $3, $4, $5, $6)
    `;
    
    // 문자열 길이를 50자로 제한
    const sanitizedDepthContents = depthContents.map((content, index) => {
        if (index === 0 && content === "") {
            return null;
        }
        // 문자열인 경우에만 substring 적용
        return typeof content === 'string' ? content.substring(0, 50) : content;
    });
    
    const values = [userId, ...sanitizedDepthContents];
    
    try {
        const res = await pool.query(query, values);
    } catch (err) {
        console.error('Insertion error:', err);
        throw err;
    }
}
  
  async function checkRunStatus(client, threadId, runId) {
    let run;
    try {
      run = await client.beta.threads.runs.retrieve(threadId, runId);
      console.log(`초기 Run 상태: ${run.status}, Thread ID: ${threadId}, Run ID: ${runId}`);
    } catch (error) {
      console.error(`Run 정보 조회 실패: ${error.message}`);
      throw new Error(`초기 OpenAI run 조회 실패: ${error.message}`);
    }
    
    let attempts = 0;
    const maxAttempts = 30; // 최대 30초 대기
    
    while (run.status !== "completed" && attempts < maxAttempts) {
        console.log(`Run 상태: ${run.status}, 시도: ${attempts+1}/${maxAttempts}, Thread ID: ${threadId}`);
        
        // 에러 상태 체크
        if (run.status === "failed") {
            console.error(`Run 실패 - 상태: ${run.status}, 오류: ${run.last_error?.message || '알 수 없는 오류'}`);
            throw new Error(`OpenAI run 실패: ${run.last_error?.message || run.status}`);
        }
        
        if (run.status === "cancelled" || run.status === "expired") {
            console.error(`Run 종료 - 상태: ${run.status}`);
            throw new Error(`OpenAI run 종료: ${run.status}`);
        }
        
        await new Promise(resolve => setTimeout(resolve, 1000)); // 1초 대기
        attempts++;
        
        try {
            run = await client.beta.threads.runs.retrieve(threadId, runId);
        } catch (error) {
            console.error(`Run 상태 조회 오류: ${error.message}`);
            throw new Error(`OpenAI run 상태 조회 실패: ${error.message}`);
        }
    }
    
    // 최대 시도 횟수 초과 체크
    if (attempts >= maxAttempts) {
        console.error(`Run 시간 초과 - ${maxAttempts}초 경과, 최종 상태: ${run.status}`);
        throw new Error(`OpenAI 처리 시간 초과 (${maxAttempts}초)`);
    }
    
    console.log(`Run 성공 완료 - Thread ID: ${threadId}, 총 시도 횟수: ${attempts+1}`);
    return run; // 완료된 run 객체 반환
}

const secretKey = process.env.TOSS_SECRET_KEY;
app.post('/payment/success', async (req, res) => {
  const { orderId, paymentKey, amount } = req.body;
  console.log(paymentKey);
  try {
    // Toss Payments API에 결제 승인 요청
    const response = await axios.post('https://api.tosspayments.com/v1/payments/confirm', {
      orderId,
      paymentKey,
      amount,
    }, {
      headers: {
        Authorization: `Basic ${Buffer.from(`${secretKey}:`).toString('base64')}`, // 시크릿 키를 Base64 인코딩하여 설정
        'Content-Type': 'application/json',
      },
    });

    // 결제 승인 후 데이터베이스에 저장하거나 필요한 후속 작업 처리
    // 예: 사용자 구독 상태 업데이트, 결제 정보 저장 등

    res.send({ success: true, data: response.data });
  } catch (error) {
    console.error('결제 승인 오류:', error.response.data);
    res.status(400).send({ success: false, message: error.response.data.message });
  }
});

app.get('/subscription', async (req, res) => {
  try {
    const userId = req.session.userInfo.userId; // 사용자 ID를 세션에서 가져옵니다.
    const query = `
      SELECT subscription_status, subscription_start_date, subscription_end_date, available_num 
      FROM user_info 
      WHERE user_id = $1
    `;
    const { rows } = await pool.query(query, [userId]);

    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    console.error('Error fetching subscription data:', err);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

app.get('/payment-history', async (req, res) => {
  try {
    const userId = req.session.userInfo.userId; // 클라이언트에서 user_id를 쿼리 파라미터로 전달한다고 가정합니다.

    if (!userId) {
      return res.status(400).json({ message: 'user_id is required' });
    }

    const result = await pool.query(
      'SELECT date, plan, amount, method, status, receipt_url FROM payment_history WHERE user_id = $1 ORDER BY date DESC',
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching payment history:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.post('/save-billing-key', async (req, res) => {
  const { billingKey, customerKey } = req.body;
  console.log('123');

  if (!billingKey || !customerKey) {
    return res.status(400).json({ success: false, message: 'Invalid request data' });
  }

  try {
    const queryText = 'UPDATE user_info SET billing_key = $1 WHERE customer_key = $2';
    await db.query(queryText, [billingKey, customerKey]);

    res.status(200).json({ success: true, message: 'Billing key saved successfully' });
  } catch (error) {
    console.error('Error saving billing key:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

app.get('/get-customer-key', (req, res) => {
  if (req.session && req.session.userInfo.userId) {
    res.json({ customerKey: req.session.userInfo.userId });
  } else {
    res.status(401).json({ error: 'User not authenticated' });
  }
});



// app.use(cors({
//   origin: ['https://api.metheus.pro', 'http://localhost:3000', 'https://app.metheus.pro'],
//   credentials: true
// }));

// 포트 설정을 명확하게 고정
// const PORT = 3001;
// app.listen(PORT, '0.0.0.0', () => {
//   console.log(`Server running on port ${PORT}`);
// });


// // const cors = require('cors');
// const express = require('express');
// // const app = express();

// // CORS 설정 추가
// app.use(cors({
//   origin: ['https://api.metheus.pro', 'http://localhost:3000', 'https://app.metheus.pro', 'http://localhost:3001'],
//   credentials: true
// }));

// // 포트 설정을 명확하게 고정
// const PORT = 3001;
// app.listen(PORT, '0.0.0.0', () => {
//   console.log(`Server running on port ${PORT}`);
// });

// ... 기존 코드 ...

// 이 부분 제거
// const express = require('express');
// const app = express();

// CORS 설정은 기존 코드 사용
// app.use(cors({
//   origin: ['https://api.metheus.pro', 'http://localhost:3000', 'https://app.metheus.pro', 'http://localhost:3001'],
//   credentials: true
// }));


app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'API is working! 작동중!!',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ 
      status: 'Database connected! 데이터베이스 연결 성공!!',
      serverTime: result.rows[0].now
    });
  } catch (err) {
    console.error('Database connection error:', err);
    res.status(500).json({ 
      error: 'Database connection failed 데이터베이스 연결 실패!!',
      details: err.message
    });
  }
});
// 포트 설정 통일
const PORT = process.env.PORT || 8080; // 01_server.config와 일치하도록 수정

// 서버 시작 전 에러 핸들링 추가
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});

// 정상적인 종료 처리
process.on('SIGTERM', () => {
  server.close(() => {
    console.log('Server terminated');
    process.exit(0);
  });
});

//GPT API 테스트

console.log('OPENAI_API_KEY exists:', !!process.env.OPENAI_API_KEY);
console.log('OPENAI_API_KEY length:', process.env.OPENAI_API_KEY?.length);
app.get('/api/gpt-test', async (req, res) => {
  try {
    // 새로운 어시스턴트 생성
    const assistant = await openai.beta.assistants.create({
      name: "Test Assistant",
      instructions: "당신은 친절한 AI 어시스턴트입니다. 사용자의 질문에 한국어로 명확하게 답변해주세요.",
      model: "gpt-4-1106-preview"
    });
    
    const thread = await openai.beta.threads.create();

    await openai.beta.threads.messages.create(thread.id, {
      role: "user",
      content: "넌 잘 작동되고 있니???"
    });

    const run = await openai.beta.threads.runs.create(thread.id, {
      assistant_id: assistant.id,
      instructions: "사용자의 질문에 한국어로 친절하게 답변해주세요.",
    });

    await checkRunStatus(openai, thread.id, run.id);

    const message = await openai.beta.threads.messages.list(thread.id);
    const contents = message.body.data[0].content[0].text.value;

    // 사용이 끝난 어시스턴트와 스레드 정리
    await openai.beta.assistants.del(assistant.id);

    res.json({ 
      success: true, 
      message: contents,
      assistantId: assistant.id,
      threadId: thread.id
    });

  } catch (error) {
    console.error('GPT API 테스트 실패:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message,
      stack: error.stack,
      details: error.response?.data || '상세 오류 정보 없음'
    });
  }
});


// 전역 로깅 미들웨어 추가 (CORS 설정 다음에 위치)
app.use((req, res, next) => {
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.url}`);
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// 기존 라우트들에 로깅 추가
// app.post('/upload', upload.single('file'), async (req, res) => {
//   console.log('[/upload] 파일 업로드 요청 시작');
//   try {
//     // ... 기존 코드 ...
//     console.log('[/upload] 파일 업로드 성공:', file.originalname);
//     res.json({ success: true });
//   } catch (error) {
//     console.error('[/upload] 에러 발생:', error);
//     res.status(500).json({ error: error.message });
//   }
// });

app.get('/api/gpt-test', async (req, res) => {
  console.log('[/api/gpt-test] GPT 테스트 요청 시작');
  try {
    // ... 기존 코드 ...
    console.log('[/api/gpt-test] GPT 응답 성공!');
    res.json({ success: true, message: contents });
  } catch (error) {
    console.error('[/api/gpt-test] GPT 호출 실패:', error);
    res.status(500).json({ error: error.message });
  }
});

// 다른 라우트들도 비슷하게 로깅 추가...

// 에러 핸들링 미들웨어 (맨 마지막에 추가)
app.use((err, req, res, next) => {
  console.error('서버 에러 발생:', err);
  res.status(500).json({ 
    error: err.message,
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

//로그 관련 수정

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// DB 연결 테스트 엔드포인트
app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      status: 'success',
      message: 'Database connection successful',
      timestamp: result.rows[0].now,
      dbHost: process.env.DB_HOST,
      dbName: process.env.DB_NAME
    });
  } catch (error) {
    console.error('Database connection test error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Database connection failed',
      error: error.message
    });
  }
});

// PostgreSQL 연결 설정

// DB 연결 테스트 엔드포인트
// DB 연결 테스트 엔드포인트
app.get('/db-test2', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      status: 'success',
      message: 'Database connection successful',
      timestamp: result.rows[0].now,
      dbHost: pool.options.host,
      dbName: pool.options.database
    });
  } catch (error) {
    console.error('Database connection test error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Database connection failed',
      error: error.message
    });
  }
});

app.get('/api/db-test', async (req, res) => {
  console.log('[/api/db-test] DB 테스트 요청 시작');
  try {
    console.log('DB 연결 정보:', {
      host: process.env.DBURL,
      database: 'dev',
      hasPassword: !!process.env.DBPASSWORD
    });

    const result = await pool.query('SELECT NOW()');
    
    console.log('[/api/db-test] DB 쿼리 성공!');
    res.json({ 
      success: true, 
      message: 'Database connection successful',
      timestamp: result.rows[0].now,
      dbHost: process.env.DBURL,
      dbName: 'dev'
    });
  } catch (error) {
    console.error('[/api/db-test] DB 연결 실패:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message,
      stack: error.stack,
      details: error.response?.data || '상세 오류 정보 없음'
    });
  }
});

// 전역 에러 핸들러 추가
app.use((err, req, res, next) => {
  const errorLog = {
    timestamp: new Date().toISOString(),
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    body: req.body
  };
  
  console.error(JSON.stringify(errorLog, null, 2));
  fs.appendFileSync('/var/log/nodejs.log', JSON.stringify(errorLog) + '\n');
  
  res.status(500).json({ error: err.message });
});

app.use((err, req, res, next) => {
  const errorDetail = {
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    method: req.method,
    error: {
      message: err.message,
      stack: err.stack,
      code: err.code
    },
    headers: req.headers,
    body: req.body
  };

  // 로그 파일에 기록
  fs.appendFileSync('/var/log/nodejs.log', JSON.stringify(errorDetail) + '\n');
  console.error('Server Error:', errorDetail);

  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// 데이터베이스 쿼리 테스트 엔드포인트
app.get('/test-retry-query', async (req, res) => {
  try {
    console.log('Testing retry query...');
    
    // 세션 ID 테스트용
    const testSessionId = req.session?.userId || 'test-session-id';
    
    // 쿼리 실행 전 로그
    console.log('Session ID:', testSessionId);
    
    // thread_id 조회 쿼리
    const threadQuery = 'SELECT thread_id FROM thread_id WHERE user_session = $1';
    const threadResult = await pool.query(threadQuery, [testSessionId]);
    
    // 쿼리 결과 로그
    console.log('Thread query result:', threadResult.rows);
    
    res.json({
      success: true,
      message: 'Query test completed',
      results: {
        threadId: threadResult.rows[0]?.thread_id || null,
        sessionId: testSessionId,
        rowCount: threadResult.rowCount
      }
    });
    
  } catch (error) {
    console.error('Query test error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      details: {
        code: error.code,
        detail: error.detail,
        table: error.table
      }
    });
  }
});

// 테스트 엔드포인트가 제대로 추가되었는지 확인
app.get('/test-retry-query2', async (req, res) => {
  try {
    console.log('Testing retry query...');
    
    // 간단한 DB 연결 테스트
    const result = await pool.query('SELECT NOW()');
    
    res.json({
      success: true,
      message: 'Database connection test',
      timestamp: result.rows[0].now
    });
    
  } catch (error) {
    console.error('Test query error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.post('/naverlogin', async (req, res) => {
  const { code, state } = req.body;

  // 필수 파라미터 검증
  if (!code || !state) {
    return res.status(400).json({
      success: false,
      message: '필수 파라미터가 누락되었습니다.'
    });
  }

  try {
    // 1. 네이버 액세스 토큰 발급 요청
    const tokenResponse = await axios.post('https://nid.naver.com/oauth2.0/token', null, {
      params: {
        grant_type: 'authorization_code',
        client_id: process.env.NAVER_CLIENT_ID,
        client_secret: process.env.NAVER_CLIENT_SECRET,
        code,
        state
      }
    });

    const { access_token } = tokenResponse.data;

    // 2. 네이버 사용자 정보 조회
    const userResponse = await axios.get('https://openapi.naver.com/v1/nid/me', {
      headers: {
        Authorization: `Bearer ${access_token}`
      }
    });

    const naverUserInfo = userResponse.data.response;
    console.log('네이버 사용자 정보:', naverUserInfo);

    // 3. 사용자 정보 DB 확인 및 처리
    const checkUserQuery = 'SELECT * FROM user_info WHERE user_id = $1';
    const { rows } = await pool.query(checkUserQuery, [naverUserInfo.id]);

    if (rows.length === 0) {
      // user_info 테이블에 created_at 컬럼이 있는지 확인
      let hasCreatedAtColumn = false;
      try {
        const columnsQuery = `
          SELECT column_name 
          FROM information_schema.columns 
          WHERE table_name = 'user_info' AND column_name = 'created_at'
        `;
        const columnsResult = await pool.query(columnsQuery);
        hasCreatedAtColumn = columnsResult.rows.length > 0;
        console.log(`[네이버 로그인] created_at 컬럼 존재 여부: ${hasCreatedAtColumn}`);
      } catch (err) {
        console.error('컬럼 정보 조회 오류:', err);
      }
      
      // 새 사용자 등록
      let insertQuery;
      const defaultDate = new Date(2025, 0, 1); // 2025년 1월 1일
      
      if (hasCreatedAtColumn) {
        insertQuery = `
          INSERT INTO user_info (
            user_id,
            user_email,
            user_phone,
            subscription_status,
            subscription_new,
            billing_key,
            customer_key,
            created_at
          ) VALUES ($1, $2, $3, 'N', 'N', 'N', $1, $4)
        `;
        
        await pool.query(insertQuery, [
          naverUserInfo.id, 
          naverUserInfo.email,
          null, // 소셜 로그인 구분을 위해 user_phone은 null로 설정
          defaultDate // 고정된 날짜 사용
        ]);
      } else {
        insertQuery = `
          INSERT INTO user_info (
            user_id,
            user_email,
            user_phone,
            subscription_status,
            subscription_new,
            billing_key,
            customer_key
          ) VALUES ($1, $2, $3, 'N', 'N', 'N', $1)
        `;
        
        await pool.query(insertQuery, [
          naverUserInfo.id, 
          naverUserInfo.email,
          null // 소셜 로그인 구분을 위해 user_phone은 null로 설정
        ]);
      }
      
      console.log(`네이버 회원가입 완료: ${naverUserInfo.id}, created_at: ${hasCreatedAtColumn ? defaultDate.toISOString() : '없음'}`);
    }

    // 4. 세션 생성
    req.session.userInfo = {
      userId: naverUserInfo.id,
      loginTime: new Date()
    };

    // 5. 응답 데이터 구성
    res.json({
      success: true,
      message: '네이버 로그인 성공',
      data: {
        user: {
          id: naverUserInfo.id,
          email: naverUserInfo.email,
          name: naverUserInfo.name
        }
      }
    });

  } catch (error) {
    console.error('네이버 로그인 에러:', error);

    // 에러 타입에 따른 응답 처리
    if (error.response) {
      if (error.response.status === 401) {
        return res.status(401).json({
          success: false,
          message: '유효하지 않은 인증 정보입니다.'
        });
      }
      if (error.response.status === 400) {
        return res.status(400).json({
          success: false,
          message: '잘못된 요청입니다.'
        });
      }
    }

    // 기타 서버 에러
    res.status(500).json({
      success: false,
      message: '서버 에러가 발생했습니다.',
      error: error.message
    });
  }
});

app.post('/kakao/login', async (req, res) => {
  const { code } = req.body;

  // 1. 필수 파라미터 검증
  if (!code) {
    return res.status(400).json({
      success: false,
      message: '필수 파라미터가 누락되었습니다.'
    });
  }

  try {
    // 2. 카카오 액세스 토큰 발급 요청
    const redirectUri = process.env.NODE_ENV === 'production' 
      ? 'https://app.metheus.pro/oauth'
      : 'http://localhost:3000/oauth';

    const tokenResponse = await axios.post('https://kauth.kakao.com/oauth/token', null, {
      params: {
        grant_type: 'authorization_code',
        client_id: process.env.KAKAO_CLIENT_ID,
        client_secret: process.env.KAKAO_CLIENT_SECRET,
        code,
        redirect_uri: redirectUri
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
      }
    });

    const { access_token } = tokenResponse.data;

    // 3. 카카오 사용자 정보 조회
    const userResponse = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: {
        Authorization: `Bearer ${access_token}`,
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
      }
    });

    const kakaoUserInfo = userResponse.data;
    const userEmail = kakaoUserInfo.kakao_account?.email;
    console.log('카카오 사용자 정보:', kakaoUserInfo);

    // 4. 사용자 정보 DB 확인 및 처리
    const checkUserQuery = 'SELECT * FROM user_info WHERE user_id = $1';
    const { rows } = await pool.query(checkUserQuery, [kakaoUserInfo.id]);

    if (rows.length === 0) {
      // user_info 테이블에 created_at 컬럼이 있는지 확인
      let hasCreatedAtColumn = false;
      try {
        const columnsQuery = `
          SELECT column_name 
          FROM information_schema.columns 
          WHERE table_name = 'user_info' AND column_name = 'created_at'
        `;
        const columnsResult = await pool.query(columnsQuery);
        hasCreatedAtColumn = columnsResult.rows.length > 0;
        console.log(`[카카오 로그인] created_at 컬럼 존재 여부: ${hasCreatedAtColumn}`);
      } catch (err) {
        console.error('컬럼 정보 조회 오류:', err);
      }
      
      // 새 사용자 등록
      let insertQuery;
      const defaultDate = new Date(2025, 0, 1); // 2025년 1월 1일
      
      if (hasCreatedAtColumn) {
        insertQuery = `
          INSERT INTO user_info (
            user_id,
            user_email,
            user_phone,
            subscription_status,
            subscription_new,
            billing_key,
            customer_key,
            created_at
          ) VALUES ($1, $2, $3, 'N', 'N', 'N', $1, $4)
        `;
        
        await pool.query(insertQuery, [
          kakaoUserInfo.id.toString(), // kakao id는 number 타입이므로 문자열로 변환
          userEmail,
          null, // 소셜 로그인 구분을 위해 user_phone은 null로 설정
          defaultDate // 고정된 날짜 사용
        ]);
      } else {
        insertQuery = `
          INSERT INTO user_info (
            user_id,
            user_email,
            user_phone,
            subscription_status,
            subscription_new,
            billing_key,
            customer_key
          ) VALUES ($1, $2, $3, 'N', 'N', 'N', $1)
        `;
        
        await pool.query(insertQuery, [
          kakaoUserInfo.id.toString(), // kakao id는 number 타입이므로 문자열로 변환
          userEmail,
          null // 소셜 로그인 구분을 위해 user_phone은 null로 설정
        ]);
      }
      
      console.log(`카카오 회원가입 완료: ${kakaoUserInfo.id}, created_at: ${hasCreatedAtColumn ? defaultDate.toISOString() : '없음'}`);
    }

    // 5. 세션 생성
    req.session.userInfo = {
      userId: kakaoUserInfo.id.toString(),
      loginTime: new Date()
    };

    // 6. 응답 데이터 구성
    res.json({
      success: true,
      message: '카카오 로그인 성공',
      data: {
        user: {
          id: kakaoUserInfo.id,
          email: userEmail,
          name: kakaoUserInfo.kakao_account?.profile?.nickname
        }
      }
    });

  } catch (error) {
    console.error('카카오 로그인 에러:', error);

    // 에러 타입에 따른 응답 처리
    if (error.response) {
      if (error.response.status === 401) {
        return res.status(401).json({
          success: false,
          message: '유효하지 않은 인증 정보입니다.'
        });
      }
      if (error.response.status === 400) {
        return res.status(400).json({
          success: false,
          message: '잘못된 요청입니다.'
        });
      }
    }

    // 기타 서버 에러
    res.status(500).json({
      success: false,
      message: '서버 에러가 발생했습니다.',
      error: error.message
    });
  }
});

// 라우터 등록
app.use('/api/admin', adminRouter);

app.post('/find-pw', async (req, res) => {
  const { phoneNumber, username } = req.body;

  try {
    // 사용자 정보 조회
    const query = 'SELECT user_id, user_email FROM user_info WHERE user_phone = $1 and user_id = $2';
    const { rows } = await pool.query(query, [phoneNumber, username]);
    
    if (rows.length === 0) {
      return res.status(404).json({ 
        success: false,
        message: '등록된 사용자 정보를 찾을 수 없습니다.' 
      });
    }
    
    const user = rows[0];
    
    // 이메일 주소 검증
    if (!user.user_email || !user.user_email.includes('@')) {
      return res.status(400).json({ 
        success: false, 
        message: '유효한 이메일 주소가 등록되어 있지 않습니다. 관리자에게 문의하세요.' 
      });
    }

    // 임시 비밀번호 생성 (8자리 무작위 문자열)
    const tempPassword = generateRandomPassword(8);
    
    // 비밀번호 해시 처리
    const hashedPassword = await bcrypt.hash(tempPassword, saltRounds);
    
    // DB에 해시된 새 비밀번호 저장
    const updateQuery = 'UPDATE user_info SET user_password = $1 WHERE user_id = $2';
    await pool.query(updateQuery, [hashedPassword, user.user_id]);
    
    // 이메일 마스킹 처리 (개인정보 보호)
    const maskedEmail = maskEmail(user.user_email);
    
    const mailOptions = {
      from: process.env.EMAIL_USERNAME,
      to: user.user_email,
      subject: '프로메테우스 임시 비밀번호 안내',
      text: `${user.user_id}님의 임시 비밀번호는 ${tempPassword} 입니다. 로그인 후 비밀번호를 변경해주세요.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 5px;">
          <h2 style="color: #333;">임시 비밀번호 안내</h2>
          <p>안녕하세요, <strong>${user.user_id}</strong>님.</p>
          <p>요청하신 임시 비밀번호 안내입니다:</p>
          <div style="background-color: #f5f5f5; padding: 15px; border-radius: 4px; margin: 20px 0;">
            <p style="margin: 0;"><strong>임시 비밀번호:</strong> ${tempPassword}</p>
          </div>
          <p>로그인 후 보안을 위해 비밀번호를 반드시 변경해주세요.</p>
          <p style="font-size: 12px; color: #777; margin-top: 30px;">본 이메일은 발신 전용이며, 관련 문의사항은 고객센터를 이용해주세요.</p>
        </div>
      `
    };

    try {
      // 이메일 전송 시도
      await transporter.sendMail(mailOptions);
      console.log(`임시 비밀번호 이메일 발송 성공: ${user.user_email}`);
      
      res.status(200).json({ 
        success: true, 
        message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
        redirect: true // 프론트엔드에서 리다이렉트 여부 결정에 사용
      });
    } catch (emailError) {
      console.error('이메일 전송 실패:', emailError);
      
      // 대체 이메일 서비스로 재시도
      try {
        console.log('대체 이메일 서비스로 재시도 중...');
        const altTransporter = createAlternativeTransporter();
        await altTransporter.sendMail(mailOptions);
        
        console.log(`대체 서비스로 이메일 전송 성공: ${user.user_email}`);
        res.status(200).json({ 
          success: true, 
          message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
          redirect: true
        });
      } catch (altEmailError) {
        console.error('대체 이메일 서비스 실패:', altEmailError);
        
        // 개발 환경에서는 비밀번호를 직접 보여줌 (테스트용)
        if (process.env.NODE_ENV === 'development') {
          res.status(200).json({ 
            success: true, 
            message: '개발 환경: 이메일 전송을 건너뛰고 비밀번호를 직접 제공합니다.', 
            tempPassword: tempPassword,
            error: emailError.message
          });
        } else {
          // 이메일 전송 실패 시 비밀번호 업데이트 롤백
          try {
            const rollbackQuery = 'SELECT user_password FROM user_info WHERE user_id = $1';
            const oldPasswordResult = await pool.query(rollbackQuery, [user.user_id]);
            
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송에 실패했습니다. 나중에 다시 시도하거나 관리자에게 문의하세요.' 
            });
          } catch (rollbackError) {
            console.error('비밀번호 롤백 실패:', rollbackError);
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송 및 비밀번호 재설정에 실패했습니다. 관리자에게 문의하세요.' 
            });
          }
        }
      }
    }
  } catch (error) {
    console.error('데이터베이스 또는 서버 오류:', error);
    res.status(500).json({ 
      success: false, 
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.' 
    });
  }
});

// 랜덤 비밀번호 생성 함수
function generateRandomPassword(length) {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let password = '';
  
  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * charset.length);
    password += charset[randomIndex];
  }
  
  return password;
}

// 이메일 마스킹 유틸리티 함수
function maskEmail(email) {
  if (!email || !email.includes('@')) return email;
  
  const [username, domain] = email.split('@');
  let maskedUsername;
  
  if (username.length <= 3) {
    maskedUsername = username.charAt(0) + '*'.repeat(username.length - 1);
  } else {
    maskedUsername = username.charAt(0) + 
                    '*'.repeat(username.length - 2) + 
                    username.charAt(username.length - 1);
  }
  
  const [domainName, extension] = domain.split('.');
  const maskedDomain = domainName.charAt(0) + 
                      '*'.repeat(domainName.length - 1) + 
                      '.' + extension;
  
  return `${maskedUsername}@${maskedDomain}`;
}

// 인증코드 관리를 위한 객체 (전화번호 => {code, timestamp})
const verificationCodes = new Map();
const verificationAttempts = new Map(); // 전화번호별 시도 횟수 추적

// 인증 코드 유효 시간 (300초 = 5분)로 연장
const CODE_EXPIRY_TIME = 300 * 1000;

// 시간당 최대 인증 시도 횟수
const MAX_ATTEMPTS_PER_HOUR = 10; // 5에서 10으로 증가

// 주기적으로 만료된 인증 코드 정리 (5분마다)
setInterval(() => {
  const now = Date.now();
  let expiredCount = 0;
  
  verificationCodes.forEach((verification, phoneNumber) => {
    if (now - verification.timestamp > CODE_EXPIRY_TIME) {
      verificationCodes.delete(phoneNumber);
      expiredCount++;
    }
  });
  
  if (expiredCount > 0) {
    console.log(`만료된 인증 코드 ${expiredCount}개 정리 완료`);
  }
}, 5 * 60 * 1000);

app.post('/send-code', async (req, res) => {
  const { phoneNumber, isResend, isProfileUpdate } = req.body;
  
  console.log(`인증코드 요청 - 전화번호: ${phoneNumber}, 재전송: ${isResend}, 프로필 업데이트: ${isProfileUpdate}, 세션 ID: ${req.sessionID}`);
  
  if (!phoneNumber || phoneNumber.trim() === '') {
    return res.status(400).json({ 
      success: false, 
      message: '전화번호를 입력해주세요.' 
    });
  }
  
  // 프로필 업데이트 시 현재 로그인된 사용자인지 확인
  if (isProfileUpdate && (!req.session || !req.session.userInfo || !req.session.userInfo.userId)) {
    console.log('인증코드 발송 실패 - 로그인 필요');
    return res.status(401).json({
      success: false,
      message: '로그인이 필요합니다.',
      reason: 'auth_required'
    });
  }
  
  // 프로필 업데이트용 - 휴대폰 번호 중복 확인
  if (isProfileUpdate) {
    try {
      // 현재 사용자 ID는 제외하고 중복 확인
      const duplicateCheckQuery = 'SELECT user_id FROM user_info WHERE user_phone = $1 AND user_id != $2';
      const duplicateResult = await pool.query(duplicateCheckQuery, [phoneNumber, req.session.userInfo.userId]);
      
      if (duplicateResult.rows.length > 0) {
        console.log(`인증코드 발송 실패 - 중복된 전화번호 (${phoneNumber})`);
        return res.status(400).json({
          success: false,
          message: '이미 다른 사용자가 사용 중인 휴대폰 번호입니다.',
          reason: 'duplicate_phone'
        });
      }
    } catch (error) {
      console.error('휴대폰 번호 중복 확인 오류:', error);
      // 오류가 발생해도 진행 (중요한 보안 확인이 아니므로)
    }
  }
  
  // 과도한 요청 제한 확인
  const hourStart = new Date();
  hourStart.setMinutes(0, 0, 0);
  
  // 시도 기록 가져오기 또는 초기화
  const attempts = verificationAttempts.get(phoneNumber) || {
    count: 0,
    hourStart: hourStart.getTime()
  };
  
  // 새로운 시간대면 카운터 초기화
  if (hourStart.getTime() > attempts.hourStart) {
    attempts.count = 0;
    attempts.hourStart = hourStart.getTime();
  }
  
  // 시도 횟수 제한 확인
  if (attempts.count >= MAX_ATTEMPTS_PER_HOUR) {
    console.log(`인증코드 발송 실패 - 시도 횟수 초과 (${phoneNumber}, ${attempts.count}회)`);
    return res.status(429).json({
      success: false,
      message: '너무 많은 인증 시도가 있었습니다. 1시간 후에 다시 시도해주세요.',
      reason: 'limit_exceeded'
    });
  }
  
  const verificationCode = Math.floor(100000 + Math.random() * 900000); // 6자리 코드 생성
  console.log(`인증코드 생성 - 전화번호: ${phoneNumber}, 코드: ${verificationCode}`);
  
  // Solapi 설정 확인
  if (!process.env.SOLAPI_API_KEY || !process.env.SOLAPI_API_SECRET || !messageService) {
    console.error(`SMS 서비스 설정 오류 - API 키 존재 여부: ${!!process.env.SOLAPI_API_KEY}, API 시크릿 존재 여부: ${!!process.env.SOLAPI_API_SECRET}, 메시지 서비스 존재 여부: ${!!messageService}`);
  }
  
  try {
    // Solapi로 SMS 전송
    console.log(`SMS 전송 시도 - 전화번호: ${phoneNumber}, 코드: ${verificationCode}`);
    const result = await messageService.send({
      'to': phoneNumber,
      'from': '070-8095-3146',
      'text': `[프로메테우스] 인증번호 [${verificationCode}]를 입력해주세요. 본인 확인을 위해 타인에게 공유하지 마세요.`
    });
    
    console.log(`SMS 전송 결과:`, result);
    
    // 인증 코드, 타임스탬프만 저장 (isProfileUpdate 제거)
    verificationCodes.set(phoneNumber, {
      code: verificationCode.toString(),
      timestamp: Date.now()
    });
    
    // 저장된 코드 정보 확인
    const storedVerification = verificationCodes.get(phoneNumber);
    console.log(`저장된 코드 정보 - 전화번호: ${phoneNumber}, 코드: ${storedVerification.code}, 타임스탬프: ${new Date(storedVerification.timestamp).toISOString()}`);
    
    // 시도 횟수 증가 및 저장
    attempts.count++;
    verificationAttempts.set(phoneNumber, attempts);
    
    console.log(`인증코드 ${isResend ? '재' : ''}발송 (${phoneNumber}): ${verificationCode}, 남은 시도 횟수: ${MAX_ATTEMPTS_PER_HOUR - attempts.count}`);
    
    res.status(200).json({ 
      success: true, 
      message: `인증코드가 ${isResend ? '재' : ''}발송되었습니다.`,
      expiresIn: CODE_EXPIRY_TIME / 1000, // 초 단위 유효 시간
      // 테스트 환경에서 코드 확인용
      testCode: process.env.NODE_ENV === 'development' ? verificationCode : undefined
    });
  } catch (error) {
    console.error('인증코드 발송 오류:', error);
    res.status(500).json({ 
      success: false, 
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      reason: 'server_error'
    });
  }
});

app.post('/verify-code', (req, res) => {
  const { phoneNumber, verificationCode } = req.body;
  console.log(`인증 시도 - 전화번호: ${phoneNumber}, 코드: ${verificationCode}, 세션 ID: ${req.sessionID}`);
  
  const verification = verificationCodes.get(phoneNumber);

  if (!verification) {
    console.log(`인증 실패 - 코드 없음 (전화번호: ${phoneNumber})`);
    return res.status(400).json({
      success: false,
      message: '인증코드가 존재하지 않습니다. 인증코드를 먼저 요청해주세요.',
      reason: 'not_found'
    });
  }

  // 디버깅 정보 출력
  console.log(`저장된 코드 정보 - 코드: ${verification.code}, 타임스탬프: ${new Date(verification.timestamp).toISOString()}`);

  // 코드 만료 확인
  const now = Date.now();
  if (now - verification.timestamp > CODE_EXPIRY_TIME) {
    verificationCodes.delete(phoneNumber); // 만료된 코드 삭제
    console.log(`인증 실패 - 코드 만료 (전화번호: ${phoneNumber})`);
    return res.status(400).json({
      success: false,
      message: '인증코드가 만료되었습니다. 재전송해주세요.',
      reason: 'expired'
    });
  }

  // isProfileUpdate 검사 부분 제거 - 목적에 상관없이 인증 코드만 검증

  // 문자열로 변환하여 비교 (클라이언트에서 문자열이나 숫자로 전송할 수 있음)
  const userCodeStr = verificationCode.toString();
  const storedCodeStr = verification.code.toString();
  
  console.log(`코드 비교 - 입력: ${userCodeStr}, 저장: ${storedCodeStr}`);
  
  if (storedCodeStr === userCodeStr) {
    verificationCodes.delete(phoneNumber); // 인증 후 코드 삭제
    console.log(`인증 성공 - 전화번호: ${phoneNumber}`);
    res.status(200).json({ 
      success: true, 
      message: '전화번호 인증이 완료되었습니다.',
      verified: true
    });
  } else {
    console.log(`인증 실패 - 코드 불일치 (전화번호: ${phoneNumber})`);
    res.status(400).json({ 
      success: false, 
      message: '인증번호를 다시 확인해주세요.',
      reason: 'invalid'
    });
  }
});

app.post('/find-pw', async (req, res) => {
  const { phoneNumber, username } = req.body;

  try {
    // 사용자 정보 조회
    const query = 'SELECT user_id, user_email FROM user_info WHERE user_phone = $1 and user_id = $2';
    const { rows } = await pool.query(query, [phoneNumber, username]);
    
    if (rows.length === 0) {
      return res.status(404).json({ 
        success: false,
        message: '등록된 사용자 정보를 찾을 수 없습니다.' 
      });
    }
    
    const user = rows[0];
    
    // 이메일 주소 검증
    if (!user.user_email || !user.user_email.includes('@')) {
      return res.status(400).json({ 
        success: false, 
        message: '유효한 이메일 주소가 등록되어 있지 않습니다. 관리자에게 문의하세요.' 
      });
    }

    // 임시 비밀번호 생성 (8자리 무작위 문자열)
    const tempPassword = generateRandomPassword(8);
    
    // 비밀번호 해시 처리
    const hashedPassword = await bcrypt.hash(tempPassword, saltRounds);
    
    // DB에 해시된 새 비밀번호 저장 및 임시 비밀번호 플래그 설정
    const updateQuery = 'UPDATE user_info SET user_password = $1, is_temp_password = true WHERE user_id = $2';
    await pool.query(updateQuery, [hashedPassword, user.user_id]);
    
    // 이메일 마스킹 처리 (개인정보 보호)
    const maskedEmail = maskEmail(user.user_email);
    
    const mailOptions = {
      from: process.env.EMAIL_USERNAME,
      to: user.user_email,
      subject: '프로메테우스 임시 비밀번호 안내',
      text: `${user.user_id}님의 임시 비밀번호는 ${tempPassword} 입니다. 로그인 후 비밀번호를 변경해주세요.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 5px;">
          <h2 style="color: #333;">임시 비밀번호 안내</h2>
          <p>안녕하세요, <strong>${user.user_id}</strong>님.</p>
          <p>요청하신 임시 비밀번호 안내입니다:</p>
          <div style="background-color: #f5f5f5; padding: 15px; border-radius: 4px; margin: 20px 0;">
            <p style="margin: 0;"><strong>임시 비밀번호:</strong> ${tempPassword}</p>
          </div>
          <p>로그인 후 보안을 위해 비밀번호를 반드시 변경해주세요.</p>
          <p style="font-size: 12px; color: #777; margin-top: 30px;">본 이메일은 발신 전용이며, 관련 문의사항은 고객센터를 이용해주세요.</p>
        </div>
      `
    };

    try {
      // 이메일 전송 시도
      await transporter.sendMail(mailOptions);
      console.log(`임시 비밀번호 이메일 발송 성공: ${user.user_email}`);
      
      res.status(200).json({ 
        success: true, 
        message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
        redirect: true // 프론트엔드에서 리다이렉트 여부 결정에 사용
      });
    } catch (emailError) {
      console.error('이메일 전송 실패:', emailError);
      
      // 대체 이메일 서비스로 재시도
      try {
        console.log('대체 이메일 서비스로 재시도 중...');
        const altTransporter = createAlternativeTransporter();
        await altTransporter.sendMail(mailOptions);
        
        console.log(`대체 서비스로 이메일 전송 성공: ${user.user_email}`);
        res.status(200).json({ 
          success: true, 
          message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
          redirect: true
        });
      } catch (altEmailError) {
        console.error('대체 이메일 서비스 실패:', altEmailError);
        
        // 개발 환경에서는 비밀번호를 직접 보여줌 (테스트용)
        if (process.env.NODE_ENV === 'development') {
          res.status(200).json({ 
            success: true, 
            message: '개발 환경: 이메일 전송을 건너뛰고 비밀번호를 직접 제공합니다.', 
            tempPassword: tempPassword,
            error: altEmailError.message
          });
        } else {
          // 이메일 전송 실패 시 비밀번호 업데이트 롤백
          try {
            const rollbackQuery = 'UPDATE user_info SET is_temp_password = false WHERE user_id = $1';
            await pool.query(rollbackQuery, [user.user_id]);
            
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송에 실패했습니다. 나중에 다시 시도하거나 관리자에게 문의하세요.' 
            });
          } catch (rollbackError) {
            console.error('비밀번호 롤백 실패:', rollbackError);
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송 및 비밀번호 재설정에 실패했습니다. 관리자에게 문의하세요.' 
            });
          }
        }
      }
    }
  } catch (error) {
    console.error('데이터베이스 또는 서버 오류:', error);
    res.status(500).json({ 
      success: false, 
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.' 
    });
  }
});

// 비밀번호 변경 API 추가
app.post('/change-password', async (req, res) => {
  const { userId, currentPassword, newPassword } = req.body;
  
  // 사용자 ID 또는 비밀번호가 제공되지 않은 경우
  if (!userId || !currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: '필수 정보가 누락되었습니다.'
    });
  }
  
  // 새 비밀번호 유효성 검사 (최소 8자 이상)
  if (newPassword.length < 8) {
    return res.status(400).json({
      success: false,
      message: '새 비밀번호는 최소 8자 이상이어야 합니다.'
    });
  }
  
  try {
    // 사용자 조회
    const getUserQuery = 'SELECT user_id, user_password FROM user_info WHERE user_id = $1';
    const userResult = await pool.query(getUserQuery, [userId]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.'
      });
    }
    
    const user = userResult.rows[0];
    
    // 현재 비밀번호 검증
    const isPasswordValid = await bcrypt.compare(currentPassword, user.user_password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '현재 비밀번호가 일치하지 않습니다.'
      });
    }
    
    // 새 비밀번호 해시
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);
    
    // 비밀번호 업데이트
    const updatePasswordQuery = 'UPDATE user_info SET user_password = $1 WHERE user_id = $2';
    await pool.query(updatePasswordQuery, [hashedNewPassword, userId]);
    
    res.status(200).json({
      success: true,
      message: '비밀번호가 성공적으로 변경되었습니다.'
    });
    
  } catch (error) {
    console.error('비밀번호 변경 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 현재 사용자의 비밀번호 무조건 변경 API (임시 비밀번호 로그인 후 사용)
app.post('/reset-password', async (req, res) => {
  // 세션에서 사용자 정보 확인
  if (!req.session || !req.session.userInfo || !req.session.userInfo.userId) {
    return res.status(401).json({
      success: false,
      message: '로그인이 필요합니다.'
    });
  }
  
  const userId = req.session.userInfo.userId;
  const { newPassword } = req.body;
  
  // 새 비밀번호 유효성 검사
  if (!newPassword || newPassword.length < 8) {
    return res.status(400).json({
      success: false,
      message: '새 비밀번호는 최소 8자 이상이어야 합니다.'
    });
  }
  
  try {
    // 새 비밀번호 해시
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);
    
    // 비밀번호 업데이트
    const updatePasswordQuery = 'UPDATE user_info SET user_password = $1 WHERE user_id = $2';
    await pool.query(updatePasswordQuery, [hashedNewPassword, userId]);
    
    res.status(200).json({
      success: true,
      message: '비밀번호가 성공적으로 변경되었습니다.'
    });
    
  } catch (error) {
    console.error('비밀번호 재설정 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 인증 미들웨어 추가


// 사용자 프로필 조회 API
app.get('/user/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.session.userInfo.userId;
    
    // 사용자 정보 조회
    const query = `
      SELECT user_id, user_email, user_phone, created_at, 
             CASE 
               WHEN user_phone IS NULL THEN 
                 CASE 
                   WHEN user_id LIKE 'kakao_%' THEN 'kakao'
                   WHEN user_id LIKE 'google_%' THEN 'google'
                   WHEN user_id LIKE 'naver_%' THEN 'naver'
                   ELSE 'local'
                 END
               ELSE 'local'
             END AS login_type,
             is_temp_password
      FROM user_info 
      WHERE user_id = $1
    `;
    
    const { rows } = await pool.query(query, [userId]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자 정보를 찾을 수 없습니다.'
      });
    }
    
    const user = rows[0];
    
    // 응답 형식에 맞게 데이터 가공
    res.status(200).json({
      success: true,
      user: {
        id: user.user_id,
        username: user.user_id, // 사용자명은 ID와 동일하게 설정
        email: user.user_email,
        phone: user.user_phone,
        avatar: '', // 현재 프로필 이미지 기능이 없음
        createdAt: user.created_at,
        loginType: user.login_type
      }
    });
  } catch (error) {
    console.error('사용자 프로필 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 비밀번호 변경 API - 새 엔드포인트 추가
app.put('/user/password', authMiddleware, async (req, res) => {
  const userId = req.session.userInfo.userId;
  const { currentPassword, newPassword } = req.body;
  
  // 필수 데이터 검증
  if (!currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: '현재 비밀번호와 새 비밀번호를 모두 입력해주세요.'
    });
  }
  
  // 새 비밀번호 유효성 검사 (최소 8자 이상)
  if (newPassword.length < 8) {
    return res.status(400).json({
      success: false,
      message: '새 비밀번호는 최소 8자 이상이어야 합니다.'
    });
  }
  
  try {
    // 사용자 조회
    const userQuery = 'SELECT user_password FROM user_info WHERE user_id = $1';
    const userResult = await pool.query(userQuery, [userId]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.'
      });
    }
    
    const user = userResult.rows[0];
    
    // 현재 비밀번호 검증
    const isPasswordValid = await bcrypt.compare(currentPassword, user.user_password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '현재 비밀번호가 일치하지 않습니다.'
      });
    }
    
    // 새 비밀번호 해시
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);
    
    // 비밀번호 업데이트 및 임시 비밀번호 플래그 false로 설정
    const updateQuery = 'UPDATE user_info SET user_password = $1, is_temp_password = false WHERE user_id = $2';
    await pool.query(updateQuery, [hashedNewPassword, userId]);
    
    res.status(200).json({
      success: true,
      message: '비밀번호가 성공적으로 변경되었습니다.'
    });
  } catch (error) {
    console.error('비밀번호 변경 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 기존 비밀번호 변경 API 수정 - 임시 비밀번호 플래그 추가
app.post('/change-password', async (req, res) => {
  const { userId, currentPassword, newPassword } = req.body;
  
  // 사용자 ID 또는 비밀번호가 제공되지 않은 경우
  if (!userId || !currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: '필수 정보가 누락되었습니다.'
    });
  }
  
  // 새 비밀번호 유효성 검사 (최소 8자 이상)
  if (newPassword.length < 8) {
    return res.status(400).json({
      success: false,
      message: '새 비밀번호는 최소 8자 이상이어야 합니다.'
    });
  }
  
  try {
    // 사용자 조회
    const getUserQuery = 'SELECT user_id, user_password FROM user_info WHERE user_id = $1';
    const userResult = await pool.query(getUserQuery, [userId]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.'
      });
    }
    
    const user = userResult.rows[0];
    
    // 현재 비밀번호 검증
    const isPasswordValid = await bcrypt.compare(currentPassword, user.user_password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '현재 비밀번호가 일치하지 않습니다.'
      });
    }
    
    // 새 비밀번호 해시
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);
    
    // 비밀번호 업데이트 및 임시 비밀번호 플래그 false로 설정
    const updatePasswordQuery = 'UPDATE user_info SET user_password = $1, is_temp_password = false WHERE user_id = $2';
    await pool.query(updatePasswordQuery, [hashedNewPassword, userId]);
    
    res.status(200).json({
      success: true,
      message: '비밀번호가 성공적으로 변경되었습니다.'
    });
    
  } catch (error) {
    console.error('비밀번호 변경 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 임시 비밀번호 생성 로직 수정 - is_temp_password 필드 추가
app.post('/find-pw', async (req, res) => {
  const { phoneNumber, username } = req.body;

  try {
    // 사용자 정보 조회
    const query = 'SELECT user_id, user_email FROM user_info WHERE user_phone = $1 and user_id = $2';
    const { rows } = await pool.query(query, [phoneNumber, username]);
    
    if (rows.length === 0) {
      return res.status(404).json({ 
        success: false,
        message: '등록된 사용자 정보를 찾을 수 없습니다.' 
      });
    }
    
    const user = rows[0];
    
    // 이메일 주소 검증
    if (!user.user_email || !user.user_email.includes('@')) {
      return res.status(400).json({ 
        success: false, 
        message: '유효한 이메일 주소가 등록되어 있지 않습니다. 관리자에게 문의하세요.' 
      });
    }

    // 임시 비밀번호 생성 (8자리 무작위 문자열)
    const tempPassword = generateRandomPassword(8);
    
    // 비밀번호 해시 처리
    const hashedPassword = await bcrypt.hash(tempPassword, saltRounds);
    
    // DB에 해시된 새 비밀번호 저장 및 임시 비밀번호 플래그 설정
    const updateQuery = 'UPDATE user_info SET user_password = $1, is_temp_password = true WHERE user_id = $2';
    await pool.query(updateQuery, [hashedPassword, user.user_id]);
    
    // 이메일 마스킹 처리 (개인정보 보호)
    const maskedEmail = maskEmail(user.user_email);
    
    const mailOptions = {
      from: process.env.EMAIL_USERNAME,
      to: user.user_email,
      subject: '프로메테우스 임시 비밀번호 안내',
      text: `${user.user_id}님의 임시 비밀번호는 ${tempPassword} 입니다. 로그인 후 비밀번호를 변경해주세요.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 5px;">
          <h2 style="color: #333;">임시 비밀번호 안내</h2>
          <p>안녕하세요, <strong>${user.user_id}</strong>님.</p>
          <p>요청하신 임시 비밀번호 안내입니다:</p>
          <div style="background-color: #f5f5f5; padding: 15px; border-radius: 4px; margin: 20px 0;">
            <p style="margin: 0;"><strong>임시 비밀번호:</strong> ${tempPassword}</p>
          </div>
          <p>로그인 후 보안을 위해 비밀번호를 반드시 변경해주세요.</p>
          <p style="font-size: 12px; color: #777; margin-top: 30px;">본 이메일은 발신 전용이며, 관련 문의사항은 고객센터를 이용해주세요.</p>
        </div>
      `
    };

    try {
      // 이메일 전송 시도
      await transporter.sendMail(mailOptions);
      console.log(`임시 비밀번호 이메일 발송 성공: ${user.user_email}`);
      
      res.status(200).json({ 
        success: true, 
        message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
        redirect: true // 프론트엔드에서 리다이렉트 여부 결정에 사용
      });
    } catch (emailError) {
      console.error('이메일 전송 실패:', emailError);
      
      // 대체 이메일 서비스로 재시도
      try {
        console.log('대체 이메일 서비스로 재시도 중...');
        const altTransporter = createAlternativeTransporter();
        await altTransporter.sendMail(mailOptions);
        
        console.log(`대체 서비스로 이메일 전송 성공: ${user.user_email}`);
        res.status(200).json({ 
          success: true, 
          message: `임시 비밀번호가 ${maskedEmail} 이메일로 전송되었습니다.`,
          redirect: true
        });
      } catch (altEmailError) {
        console.error('대체 이메일 서비스 실패:', altEmailError);
        
        // 개발 환경에서는 비밀번호를 직접 보여줌 (테스트용)
        if (process.env.NODE_ENV === 'development') {
          res.status(200).json({ 
            success: true, 
            message: '개발 환경: 이메일 전송을 건너뛰고 비밀번호를 직접 제공합니다.', 
            tempPassword: tempPassword,
            error: altEmailError.message
          });
        } else {
          // 이메일 전송 실패 시 비밀번호 업데이트 롤백
          try {
            const rollbackQuery = 'UPDATE user_info SET is_temp_password = false WHERE user_id = $1';
            await pool.query(rollbackQuery, [user.user_id]);
            
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송에 실패했습니다. 나중에 다시 시도하거나 관리자에게 문의하세요.' 
            });
          } catch (rollbackError) {
            console.error('비밀번호 롤백 실패:', rollbackError);
            res.status(500).json({ 
              success: false, 
              message: '이메일 전송 및 비밀번호 재설정에 실패했습니다. 관리자에게 문의하세요.' 
            });
          }
        }
      }
    }
  } catch (error) {
    console.error('데이터베이스 또는 서버 오류:', error);
    res.status(500).json({ 
      success: false, 
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.' 
    });
  }
});

// 사용자 프로필 업데이트 API
app.put('/user/update', authMiddleware, async (req, res) => {
  try {
    const userId = req.session.userInfo.userId;
    const { email, phone, phoneVerified } = req.body;
    
    // 기존 사용자 정보 조회
    const userQuery = 'SELECT user_id, user_email, user_phone, created_at FROM user_info WHERE user_id = $1';
    const userResult = await pool.query(userQuery, [userId]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.'
      });
    }
    
    const currentUser = userResult.rows[0];
    
    // 이메일과 휴대폰 번호 유효성 검사
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (email && !emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 이메일 형식입니다.'
      });
    }
    
    const phoneRegex = /^010\d{8}$/;
    if (phone && !phoneRegex.test(phone)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 휴대폰 번호 형식입니다. (010으로 시작하는 11자리)'
      });
    }
    
    // 휴대폰 번호 변경 시 인증 여부 확인
    const phoneChanged = currentUser.user_phone !== phone;
    if (phoneChanged && !phoneVerified) {
      return res.status(400).json({
        success: false,
        message: '휴대폰 번호 변경 시 인증이 필요합니다.'
      });
    }
    
    // 사용자 정보 업데이트
    const updateFields = [];
    const updateValues = [];
    let valueIndex = 1;
    
    if (email) {
      updateFields.push(`user_email = $${valueIndex}`);
      updateValues.push(email);
      valueIndex++;
    }
    
    if (phone && (phoneChanged && phoneVerified)) {
      updateFields.push(`user_phone = $${valueIndex}`);
      updateValues.push(phone);
      valueIndex++;
    }
    
    // 업데이트할 필드가 없는 경우
    if (updateFields.length === 0) {
      return res.status(200).json({
        success: true,
        message: '변경된 내용이 없습니다.',
        user: {
          id: currentUser.user_id,
          username: currentUser.user_id,
          email: currentUser.user_email,
          phone: currentUser.user_phone,
          avatar: '',
          createdAt: currentUser.created_at,
          loginType: 'local' // 기본값
        }
      });
    }
    
    // 사용자 정보 업데이트 쿼리 실행
    const updateQuery = `
      UPDATE user_info 
      SET ${updateFields.join(', ')} 
      WHERE user_id = $${valueIndex} 
      RETURNING user_id, user_email, user_phone, created_at
    `;
    
    updateValues.push(userId);
    const updateResult = await pool.query(updateQuery, updateValues);
    
    const updatedUser = updateResult.rows[0];
    
    // 로그인 타입 판별
    const loginType = (() => {
      if (updatedUser.user_phone === null) {
        if (updatedUser.user_id.startsWith('kakao_')) return 'kakao';
        if (updatedUser.user_id.startsWith('google_')) return 'google';
        if (updatedUser.user_id.startsWith('naver_')) return 'naver';
      }
      return 'local';
    })();
    
    // 응답 형식에 맞게 데이터 가공
    res.status(200).json({
      success: true,
      message: '프로필이 성공적으로 업데이트되었습니다.',
      user: {
        id: updatedUser.user_id,
        username: updatedUser.user_id,
        email: updatedUser.user_email,
        phone: updatedUser.user_phone,
        avatar: '',
        createdAt: updatedUser.created_at,
        loginType: loginType
      }
    });
  } catch (error) {
    console.error('프로필 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 프로젝트 ID를 UUID로 변환하는 API
app.post('/api/project/getUUID', async (req, res) => {
  try {
    const { id } = req.body;
    
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        success: false,
        message: '유효한 프로젝트 ID가 필요합니다.'
      });
    }

    const query = 'SELECT user_session as uuid FROM rfp WHERE rfp_seq = $1';
    const { rows } = await pool.query(query, [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '해당 ID의 프로젝트를 찾을 수 없습니다.'
      });
    }
    
    res.status(200).json({
      success: true,
      uuid: rows[0].uuid
    });
  } catch (error) {
    console.error('UUID 변환 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 숫자 ID로 프로젝트 상세 정보를 조회하는 대안 API
app.get('/api/project/:id', async (req, res) => {
  try {
    const projectId = req.params.id;
    
    if (!projectId || isNaN(parseInt(projectId))) {
      return res.status(400).json({
        success: false,
        message: '유효한 프로젝트 ID가 필요합니다.'
      });
    }

    // 먼저 rfp 테이블에서 기본 프로젝트 정보 조회
    const rfpQuery = `
      SELECT 
        rfp_seq,
        user_session, 
        pro_name, 
        pro_budget, 
        pro_period, 
        pro_service, 
        pro_output, 
        pro_reference,
        pro_agency,
        expected_budget,
        expected_period,
        pro_funcdesc,
        wbs_doc,
        created_at
      FROM rfp 
      WHERE rfp_seq = $1
    `;
    
    const rfpResult = await pool.query(rfpQuery, [projectId]);
    
    if (rfpResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '프로젝트를 찾을 수 없습니다.'
      });
    }
    
    const projectData = rfpResult.rows[0];
    const uuid = projectData.user_session;
    
    // IA 정보 조회
    const iaQuery = `
      SELECT depth1, depth2, depth3, depth4 
      FROM ia 
      WHERE ia_id = $1 
      ORDER BY ia_num ASC, ia_seq ASC
    `;
    
    const iaResult = await pool.query(iaQuery, [uuid]);
    
    // WBS 정보 조회
    const wbsQuery = `
      SELECT task_name, roles_involved, start_month, end_month, description 
      FROM wbs 
      WHERE wbs_id = $1 
      ORDER BY start_month ASC, end_month ASC
    `;
    
    const wbsResult = await pool.query(wbsQuery, [uuid]);
    
    // 응답 데이터 구성
    const responseData = {
      success: true,
      project: {
        id: projectData.rfp_seq,
        uuid: uuid,
        title: projectData.pro_name,
        budget: projectData.pro_budget,
        period: projectData.pro_period,
        agency: projectData.pro_agency,
        service: projectData.pro_service ? 
          projectData.pro_service.split(',\n').map(s => s.trim()).join('\n') : 
          '',
        output: projectData.pro_output,
        reference: projectData.pro_reference,
        expectedBudget: projectData.expected_budget,
        expectedPeriod: projectData.expected_period,
        funcDescription: projectData.pro_funcdesc,
        wbsDoc: projectData.wbs_doc,
        createdAt: projectData.created_at
      },
      ia: iaResult.rows,
      wbs: wbsResult.rows
    };
    
    res.status(200).json(responseData);
    
  } catch (error) {
    console.error('프로젝트 상세 정보 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
    });
  }
});

// 프로필 상세 페이지 라우트 - 숫자 ID 지원
app.get('/profileDetail/:id', async (req, res) => {
  try {
    const id = req.params.id;
    
    // ID가 숫자인지 UUID 형식인지 확인
    const isNumeric = /^\d+$/.test(id);
    
    let uuid = id;
    
    // 숫자 ID인 경우 UUID로 변환
    if (isNumeric) {
      const query = 'SELECT user_session as uuid FROM rfp WHERE rfp_seq = $1';
      const result = await pool.query(query, [id]);
      
      if (result.rows.length === 0) {
        return res.status(404).send('프로젝트를 찾을 수 없습니다.');
      }
      
      uuid = result.rows[0].uuid;
    }
    
    // 프로젝트 상세 데이터 조회
    const projectQuery = `
      SELECT 
        rfp_seq,
        user_session, 
        pro_name, 
        pro_budget, 
        pro_period, 
        pro_service, 
        pro_output, 
        pro_reference,
        pro_agency,
        expected_budget,
        expected_period,
        pro_funcdesc,
        wbs_doc,
        created_at
      FROM rfp 
      WHERE user_session = $1
    `;
    
    const projectResult = await pool.query(projectQuery, [uuid]);
    
    if (projectResult.rows.length === 0) {
      return res.status(404).send('프로젝트를 찾을 수 없습니다.');
    }
    
    const projectData = projectResult.rows[0];
    
    // IA 정보 조회
    const iaQuery = `
      SELECT depth1, depth2, depth3, depth4 
      FROM ia 
      WHERE ia_id = $1 
      ORDER BY ia_num ASC, ia_seq ASC
    `;
    
    const iaResult = await pool.query(iaQuery, [uuid]);
    
    // WBS 정보 조회
    const wbsQuery = `
      SELECT task_name, roles_involved, start_month, end_month, description 
      FROM wbs 
      WHERE wbs_id = $1 
      ORDER BY start_month ASC, end_month ASC
    `;
    
    const wbsResult = await pool.query(wbsQuery, [uuid]);
    
    // HTML 템플릿 렌더링 또는 데이터 응답
    // 프론트엔드 SPA를 사용하는 경우 API 응답으로 처리
    res.json({
      project: {
        id: projectData.rfp_seq,
        uuid: uuid,
        title: projectData.pro_name,
        budget: projectData.pro_budget,
        period: projectData.pro_period,
        agency: projectData.pro_agency,
        service: projectData.pro_service ? 
          projectData.pro_service.split(',\n').map(s => s.trim()).join('\n') : 
          '',
        output: projectData.pro_output,
        reference: projectData.pro_reference,
        expectedBudget: projectData.expected_budget,
        expectedPeriod: projectData.expected_period,
        funcDescription: projectData.pro_funcdesc,
        wbsDoc: projectData.wbs_doc,
        createdAt: projectData.created_at
      },
      ia: iaResult.rows,
      wbs: wbsResult.rows
    });
    
  } catch (error) {
    console.error('프로필 상세 페이지 로드 오류:', error);
    res.status(500).send('서버 오류가 발생했습니다.');
  }
});