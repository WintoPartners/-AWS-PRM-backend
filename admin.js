import express from 'express';
import jwt from 'jsonwebtoken';
import pkg from 'pg';
import cors from 'cors';
const { Pool } = pkg;

// 개발 환경 여부 확인
const isDevelopment = process.env.NODE_ENV === 'development';

// 모의 데이터 - 개발 환경에서 데이터베이스 연결 실패 시 사용
const mockData = {
  users: [
    {
      id: 'mock-user-1',
      email: 'user1@example.com',
      phone: '010-1234-5678',
      username: '테스트 사용자 1',
      created_at: new Date().toISOString(),
      last_login: new Date().toISOString(),
      status: '활성'
    },
    {
      id: 'mock-user-2',
      email: 'user2@example.com',
      phone: '010-9876-5432',
      username: '테스트 사용자 2',
      created_at: new Date(Date.now() - 86400000).toISOString(), // 하루 전
      last_login: new Date(Date.now() - 3600000).toISOString(), // 1시간 전
      status: '활성'
    }
  ],
  projects: [
    {
      id: 'mock-project-1',
      name: '테스트 프로젝트 1',
      user_id: 'mock-user-1',
      owner_name: '테스트 사용자 1',
      created_at: new Date().toISOString(),
      status: '진행중'
    },
    {
      id: 'mock-project-2',
      name: '테스트 프로젝트 2',
      user_id: 'mock-user-2',
      owner_name: '테스트 사용자 2',
      created_at: new Date(Date.now() - 86400000).toISOString(), // 하루 전
      status: '완료'
    }
  ],
  stats: {
    userCount: 2,
    projectCount: 2,
    todayNewUsers: 1,
    monthlyNewUsers: 2,
    recentUsers: [
      {
        id: 'mock-user-1',
        email: 'user1@example.com',
        phone: '010-1234-5678',
        username: '테스트 사용자 1',
        created_at: new Date().toISOString()
      },
      {
        id: 'mock-user-2',
        email: 'user2@example.com',
        phone: '010-9876-5432',
        username: '테스트 사용자 2',
        created_at: new Date(Date.now() - 86400000).toISOString()
      }
    ]
  }
};

// DB 연결 설정 - AWS RDS 사용하도록 수정
let pool;
try {
  // 환경 변수 확인 및 기본값 설정
  const dbUrl = process.env.DBURL || 'prm-db.cy9t8xbjdetq.ap-northeast-2.rds.amazonaws.com';
  const dbPassword = process.env.DBPASSWORD || 'postgres123!';
  const dbName = process.env.PGDATABASE || 'dev';
  
  // DB 연결 시도 - server.js와 동일한 설정 사용
  pool = new Pool({
    user: 'postgres',
    host: dbUrl,
    database: dbName,
    password: dbPassword,
    port: 5432,
    ssl: {
      rejectUnauthorized: false
    },
    // 연결 타임아웃 설정
    connectionTimeoutMillis: 5000,
  });
  
  console.log('관리자 API용 DB 풀 생성 시도:', {
    host: dbUrl,
    database: dbName
  });
  
  // 연결 테스트
  pool.query('SELECT NOW()')
    .then(() => console.log('관리자 API: 데이터베이스 연결 성공'))
    .catch(err => {
      console.error('관리자 API: 데이터베이스 연결 실패, 개발 환경에서는 모의 데이터 사용:', err.message);
    });
} catch (error) {
  console.error('DB 풀 생성 오류:', error.message);
  if (!isDevelopment) {
    throw error; // 프로덕션 환경에서는 오류 발생
  }
  // 개발 환경에서는 계속 진행
}

const router = express.Router();

// CORS 설정 로컬에서만 적용
// const corsOptions = {
//   origin: isDevelopment ? 'http://localhost:3000' : 'https://app.metheus.pro',
//   credentials: true,
//   methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
//   allowedHeaders: ['Content-Type', 'Authorization']
// };

// 라우터에 CORS 설정 적용
// router.use(cors(corsOptions));
// DB 액세스 래퍼 함수 - 안전한 DB 접근과 실패 시 모의 데이터 제공
const safeDbAccess = async (operation, mockResult) => {
  if (!pool) {
    console.log('DB 풀이 없어 모의 데이터 사용');
    return mockResult;
  }
  
  try {
    return await operation();
  } catch (error) {
    console.error('DB 액세스 오류:', error.message);
    if (isDevelopment) {
      console.log('개발 환경에서 모의 데이터 반환');
      return mockResult;
    }
    throw error;
  }
};

// 테이블 존재 확인 유틸리티 함수
const checkTableExists = async (tableName) => {
  try {
    const query = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public'
        AND table_name = $1
      )
    `;
    const result = await pool.query(query, [tableName]);
    return result.rows[0].exists;
  } catch (error) {
    console.error(`${tableName} 테이블 존재 확인 오류:`, error.message);
    return false;
  }
};

// 관리자 인증 미들웨어 - 간소화 버전
const authenticateAdmin = (req, res, next) => {
  try {
    // 간단한 토큰 확인 방식
    const token = req.headers.authorization?.split(' ')[1] || req.query.token;
    
    if (!token) {
      return res.status(401).json({ success: false, message: '인증이 필요합니다.' });
    }

    // 토큰 검증 단순화
    const SECRET_KEY = process.env.JWT_SECRET || 'admin-secret-key';
    const decoded = jwt.verify(token, SECRET_KEY);
    
    // 관리자 체크 - 간단히 isAdmin 플래그만 확인
    if (!decoded.isAdmin) {
      return res.status(403).json({ success: false, message: '관리자 권한이 없습니다.' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ success: false, message: '인증에 실패했습니다.' });
  }
};

// 디버깅용 라우트
router.get('/test', (req, res) => {
  console.log('관리자 테스트 라우트 호출됨');
  res.json({ success: true, message: '관리자 API 테스트 성공' });
});

// 데이터베이스 스키마 정보 조회 API 추가
router.get('/db-schema', authenticateAdmin, async (req, res) => {
  try {
    console.log('데이터베이스 스키마 정보 조회 요청 받음');
    
    // 테이블 목록 조회
    const tablesQuery = `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name
    `;
    
    const tables = await safeDbAccess(
      async () => {
        const result = await pool.query(tablesQuery);
        return result.rows.map(row => row.table_name);
      },
      []
    );
    
    // 각 테이블의 컬럼 조회
    const schema = {};
    
    for (const tableName of tables) {
      const columnsQuery = `
        SELECT 
          column_name, 
          data_type, 
          is_nullable,
          column_default
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1
        ORDER BY ordinal_position
      `;
      
      const columns = await safeDbAccess(
        async () => {
          const result = await pool.query(columnsQuery, [tableName]);
          return result.rows;
        },
        []
      );
      
      // 테이블 데이터 샘플 조회 (최대 5개 행)
      const sampleDataQuery = `
        SELECT * FROM "${tableName}" LIMIT 5
      `;
      
      const sampleData = await safeDbAccess(
        async () => {
          try {
            const result = await pool.query(sampleDataQuery);
            return result.rows;
          } catch (error) {
            console.error(`${tableName} 샘플 데이터 조회 오류:`, error.message);
            return [];
          }
        },
        []
      );
      
      schema[tableName] = {
        columns,
        sampleData
      };
    }
    
    // 외래 키 관계 조회
    const foreignKeysQuery = `
      SELECT
        tc.table_schema, 
        tc.constraint_name, 
        tc.table_name, 
        kcu.column_name, 
        ccu.table_schema AS foreign_table_schema,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name 
      FROM 
        information_schema.table_constraints AS tc 
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
          AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
    `;
    
    const relationships = await safeDbAccess(
      async () => {
        const result = await pool.query(foreignKeysQuery);
        return result.rows;
      },
      []
    );
    
    res.json({
      success: true,
      data: {
        tables,
        schema,
        relationships
      }
    });
  } catch (error) {
    console.error('데이터베이스 스키마 정보 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '데이터베이스 스키마 정보를 불러오는 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 관리자 로그인 API - 간소화 버전
router.post('/login', async (req, res) => {
  try {
    console.log('관리자 로그인 시도:', req.body);
    
    const { username, password } = req.body;
    
    console.log(`환경변수 확인: ${process.env.ADMIN_USERNAME}, ${process.env.ADMIN_PASSWORD}`);
    
    // 기본 관리자 계정 정보와 비교
    if (username === process.env.ADMIN_USERNAME && password === process.env.ADMIN_PASSWORD) {
      // JWT 토큰 생성 - 만료 시간 연장
      const SECRET_KEY = process.env.JWT_SECRET || 'admin-secret-key';
      const token = jwt.sign(
        { 
          isAdmin: true 
        },
        SECRET_KEY,
        { expiresIn: '30d' } // 30일로 연장
      );
      
      console.log('관리자 로그인 성공');
      
      return res.json({
        success: true,
        token
      });
    } else {
      console.log('관리자 인증 실패');
      
      return res.status(401).json({
        success: false,
        message: '인증 실패'
      });
    }
  } catch (error) {
    console.error('관리자 로그인 오류:', error);
    
    res.status(500).json({
      success: false,
      message: '서버 오류'
    });
  }
});

// 사용자 목록 조회 API
router.get('/users', authenticateAdmin, async (req, res) => {
  try {
    console.log('사용자 목록 조회 요청 받음');
    
    // 테이블 존재 여부 확인
    const usersTableExists = await checkTableExists('users');
    const userInfoTableExists = await checkTableExists('user_info');
    const rfpTableExists = await checkTableExists('rfp');
    
    console.log(`테이블 존재 여부: users=${usersTableExists}, user_info=${userInfoTableExists}, rfp=${rfpTableExists}`);
    
    if (!usersTableExists && !userInfoTableExists && !rfpTableExists) {
      console.log('관련 테이블이 존재하지 않아 모의 데이터 사용');
      return res.json({
        success: true,
        data: mockData.users
      });
    }
    
    // 사용자 정보 수집
    let allUsers = [];
    let userIds = new Set(); // 중복 방지를 위한 ID 집합
    
    // 관리자 계정(users 테이블)은 제외하고 user_info 테이블에서만 일반 사용자 가져오기
    if (userInfoTableExists) {
      try {
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
        } catch (err) {
          console.error('컬럼 정보 조회 오류:', err);
        }
        
        // 일반 사용자 조회 - user_phone도 함께 조회
        const userInfoQuery = hasCreatedAtColumn 
          ? `SELECT user_id, user_email, user_phone, created_at FROM user_info WHERE user_id IS NOT NULL`
          : `SELECT user_id, user_email, user_phone FROM user_info WHERE user_id IS NOT NULL`;
        
        const userInfoResult = await pool.query(userInfoQuery);
        
        console.log(`user_info 테이블에서 ${userInfoResult.rows.length}개 행 처리`);
        
        // user_info 테이블에서 모든 사용자 처리
        for (const info of userInfoResult.rows) {
          // 로그인 타입 판별
          const userId = String(info.user_id);
          let loginType = '일반';
          
          // 디버그: 사용자 정보 로깅
          console.log(`사용자 처리 - ID: ${userId}, 이메일: ${info.user_email}, 연락처: ${info.user_phone || '없음'}`);
          
          // 연락처 유무로 먼저 판별 (연락처가 없으면 소셜 로그인)
          const hasPhoneNumber = info.user_phone && info.user_phone.trim().length > 0;
          console.log(`연락처 여부: ${hasPhoneNumber}`);
          
          if (!hasPhoneNumber) {
            // 소셜 로그인 판별 - 네이버는 특수문자(-,_) 포함, 카카오는 숫자로만 구성
            
            // 네이버 ID 확인 - 특수문자(-,_) 포함
            if (userId.includes('-') || userId.includes('_')) {
              loginType = '네이버';
              console.log(`특수문자 포함 ID로 네이버 로그인 판별: ${userId}`);
            }
            // 카카오 ID 확인 - 숫자로만 구성
            else if (/^\d+$/.test(userId)) {
              loginType = '카카오';
              console.log(`숫자 ID로 카카오 로그인 판별: ${userId}`);
            } 
            else {
              // 기타 형태의 ID는 일반 소셜 로그인
              loginType = '소셜';
              console.log(`기타 형태의 소셜 로그인: ${userId}`);
            }
          } else {
            console.log(`연락처 있음, 일반 로그인으로 판별: ${userId}`);
          }
          
          // 생성일 처리 - created_at 필드가 없으면 2025년 1월 1일로 설정
          let createdAt;
          
          if (hasCreatedAtColumn && info.created_at) {
            // created_at 필드가 있으면 그대로 사용
            createdAt = new Date(info.created_at);
            console.log(`사용자 ${userId}의 created_at 필드 값: ${info.created_at}, 파싱 결과: ${createdAt.toISOString()}`);
            } else {
            // created_at 필드가 없으면 2025년 1월 1일로 설정
            createdAt = new Date(2025, 0, 1);
            console.log(`사용자 ${userId}의 created_at 필드 없음, 2025년 1월 1일로 설정: ${createdAt.toISOString()}`);
            }
            
            allUsers.push({
            id: info.user_id,
              user_id: info.user_id,
              email: info.user_email || '-',
            username: info.user_email 
              ? info.user_email.split('@')[0] 
              : `사용자 ${userId.substring(0, 8)}...`,
              phone: info.user_phone || '-',
            created_at: createdAt,
            status: '활성',
            login_type: loginType.toLowerCase()
          });
          
          userIds.add(info.user_id);
        }
      } catch (error) {
        console.error('user_info 테이블 처리 오류:', error);
      }
    }
    
    // 사용자 목록이 비어있으면 모의 데이터 사용
    if (allUsers.length === 0 && isDevelopment) {
      console.log('사용자 목록이 비어있어 모의 데이터 사용');
      return res.json({
        success: true,
        data: mockData.users
      });
    }
    
    // 생성일로 정렬
    allUsers.sort((a, b) => {
      if (!a.created_at && !b.created_at) return 0;
      if (!a.created_at) return 1;
      if (!b.created_at) return -1;
      return new Date(b.created_at) - new Date(a.created_at);
    });
    
    // 최종 반환 전 생성일을 ISO 문자열로 변환
    allUsers = allUsers.map(user => {
      const result = { ...user };
      if (result.created_at instanceof Date) {
        result.created_at = result.created_at.toISOString();
        console.log(`사용자 ${result.user_id}의 최종 생성일: ${result.created_at}`);
      }
      return result;
      });
      
      console.log(`사용자 관리 API: 총 ${allUsers.length}명의 사용자 반환`);
      
    res.json({
        success: true,
        data: allUsers
      });
  } catch (error) {
    console.error('사용자 목록 조회 오류:', error);
    
    // 개발 환경에서는 모의 데이터 반환
    if (isDevelopment) {
      return res.json({
        success: true,
        data: mockData.users
      });
    }
    
    res.status(500).json({
      success: false,
      message: '사용자 목록을 불러오는 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 사용자 상세 정보 조회 API 수정
router.get('/users/:userId', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`사용자 상세 정보 조회 요청: ${userId}`);
    
    // 개발 환경에서 모의 데이터 확인
    if (isDevelopment && (!pool || mockData.users.some(u => u.id === userId || u.user_id === userId))) {
      const mockUser = mockData.users.find(u => u.id === userId || u.user_id === userId) || mockData.users[0];
      const mockUserProjects = mockData.projects.filter(p => p.user_id === (mockUser.user_id || mockUser.id));
      
      return res.json({
        success: true,
        data: {
          userInfo: mockUser,
          projects: mockUserProjects
        }
      });
    }
    
    // 실제 사용자 ID 추출
    let actualUserId = userId;
    
    // ID에서 고유 ID 추출 시도 ("일반_fortest_16" 같은 형식)
    if (userId.includes('_')) {
      try {
        const parts = userId.split('_');
        // fortest 같은 특정 ID 기반 검색
        const searchUserName = parts[1];
        
        if (searchUserName) {
          console.log(`아이디로 사용자 검색: ${searchUserName}`);
          
          // user_info 테이블에서 검색
        const userInfoResult = await pool.query(
            `SELECT user_id FROM user_info WHERE user_id = $1 OR user_email LIKE $2`,
            [searchUserName, `%${searchUserName}%`]
          );
          
          if (userInfoResult.rows.length > 0) {
            actualUserId = userInfoResult.rows[0].user_id;
            console.log(`user_info 테이블에서 아이디 찾음: ${actualUserId}`);
        } else {
            console.log(`'${searchUserName}' 아이디와 일치하는 사용자를 찾을 수 없음, 원래 ID 사용`);
        }
      }
    } catch (error) {
        console.error('ID 파싱 오류:', error);
      // 계속 진행 (원래 ID로 시도)
      }
    }
    
    // 사용자 정보 조회
    let userResult = null;
    
    // user_info 테이블에서 사용자 조회
    try {
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
      } catch (err) {
        console.error('컬럼 정보 조회 오류:', err);
      }
      
      // 사용자 정보 조회 - user_phone 포함
      const userInfoQuery = hasCreatedAtColumn
        ? `SELECT user_id, user_email, user_phone, created_at FROM user_info WHERE user_id = $1 OR user_email = $1`
        : `SELECT user_id, user_email, user_phone FROM user_info WHERE user_id = $1 OR user_email = $1`;
      
      const userInfoResult = await pool.query(userInfoQuery, [actualUserId]);
      
      if (userInfoResult.rows.length > 0) {
        const userInfo = userInfoResult.rows[0];
        const userId = String(userInfo.user_id);
        
        console.log(`상세 정보 - 사용자 ${userId}, 연락처: ${userInfo.user_phone || '없음'}, 이메일: ${userInfo.user_email || '없음'}`);
        
        // 연락처 유무로 먼저 판별 (연락처가 없으면 소셜 로그인)
        const hasPhoneNumber = userInfo.user_phone && userInfo.user_phone.trim().length > 0;
        let loginType = '일반';
        
        if (!hasPhoneNumber) {
          // 소셜 로그인 판별 - 네이버는 특수문자(-,_) 포함, 카카오는 숫자로만 구성
            
          // 네이버 ID 확인 - 특수문자(-,_) 포함
          if (userId.includes('-') || userId.includes('_')) {
            loginType = '네이버';
            console.log(`특수문자 포함 ID로 네이버 로그인 판별: ${userId}`);
          }
          // 카카오 ID 확인 - 숫자로만 구성
          else if (/^\d+$/.test(userId)) {
            loginType = '카카오';
            console.log(`숫자 ID로 카카오 로그인 판별: ${userId}`);
          } 
          else {
            // 기타 형태의 ID는 일반 소셜 로그인
            loginType = '소셜';
            console.log(`기타 형태의 소셜 로그인: ${userId}`);
          }
      } else {
          console.log(`연락처 있음, 일반 로그인으로 판별: ${userId}`);
        }
        
        // 생성일 처리 - created_at 필드가 없으면 2025년 1월 1일로 설정
        let createdAt;
        
        if (hasCreatedAtColumn && userInfo.created_at) {
          // created_at 필드가 있으면 그대로 사용
          createdAt = new Date(userInfo.created_at);
          console.log(`사용자 ${userId}의 created_at 필드 값: ${userInfo.created_at}, 파싱 결과: ${createdAt.toISOString()}`);
        } else {
          // created_at 필드가 없으면 2025년 1월 1일로 설정
          createdAt = new Date(2025, 0, 1);
          console.log(`사용자 ${userId}의 created_at 필드 없음, 2025년 1월 1일로 설정: ${createdAt.toISOString()}`);
          }
          
          userResult = {
          id: userInfo.user_id,
          user_id: userInfo.user_id,
            email: userInfo.user_email || '-',
            phone: userInfo.user_phone || '-',
          username: userInfo.user_email 
            ? userInfo.user_email.split('@')[0] 
            : `사용자 ${userId.substring(0, 8)}...`,
          created_at: createdAt,
            status: '활성',
          login_type: loginType.toLowerCase()
        };
      }
    } catch (error) {
      console.error('user_info 테이블 조회 오류:', error);
    }
    
    // 사용자를 찾을 수 없는 경우
    if (!userResult) {
      return res.status(404).json({
        success: false,
        message: '해당 사용자를 찾을 수 없습니다.'
      });
    }
    
    // 사용자 프로젝트 목록 조회
      let projectsResult = [];
    try {
      // rfp 테이블에서 사용자의 프로젝트 조회
      const rfpResult = await pool.query(
        `SELECT rfp_seq, pro_name, user_id, pro_budget, pro_period, pro_service
         FROM rfp 
         WHERE user_id = $1 
         ORDER BY rfp_seq DESC`,
        [userResult.user_id]
      );
      
      if (rfpResult.rows.length > 0) {
        projectsResult = rfpResult.rows.map((project) => ({
            id: project.rfp_seq,
            name: project.pro_name || `프로젝트 ${project.rfp_seq}`,
            user_id: project.user_id,
            status: '정상',
            budget: project.pro_budget,
            period: project.pro_period,
            service: project.pro_service
        }));
      }
    } catch (error) {
      console.error('프로젝트 조회 오류:', error);
    }
    
    // created_at이 Date 객체인 경우 ISO 문자열로 변환
    if (userResult.created_at instanceof Date) {
      userResult.created_at = userResult.created_at.toISOString();
      console.log(`최종 생성일: ${userResult.created_at}`);
      }
      
      res.json({
        success: true,
        data: {
          userInfo: userResult,
          projects: projectsResult
        }
      });
  } catch (error) {
    console.error('사용자 상세 정보 조회 오류:', error);
    
    res.status(500).json({
      success: false,
      message: '사용자 상세 정보를 불러오는 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 프로젝트 목록 조회 API
router.get('/projects', authenticateAdmin, async (req, res) => {
  try {
    console.log('프로젝트 목록 조회 요청 받음');
    
    // 실제 DB 구조에 맞게 rfp 테이블 사용
    const rfpTableExists = await checkTableExists('rfp');
    if (!rfpTableExists) {
      console.log('rfp 테이블이 존재하지 않아 모의 데이터 사용');
      return res.json({
        success: true,
        data: mockData.projects
      });
    }
    
    // rfp 테이블 구조 확인
    const columnsResult = await pool.query(`
      SELECT column_name, data_type
      FROM information_schema.columns 
      WHERE table_name = 'rfp'
    `);
    
    const columns = columnsResult.rows.map(row => row.column_name);
    const dataTypes = columnsResult.rows.reduce((acc, row) => {
      acc[row.column_name] = row.data_type;
      return acc;
    }, {});
    
    console.log('rfp 테이블 컬럼 및 데이터 타입:', dataTypes);
    
    // 날짜 관련 필드 확인 (타임스탬프 또는 날짜 타입)
    let dateField = null;
    const possibleDateFields = ['created_at', 'createdAt', 'creation_date', 'submission_date', 'updated_at'];
    
    // 데이터 타입 기반으로 날짜 필드 검색
    for (const col in dataTypes) {
      if (['timestamp', 'date', 'timestamptz'].includes(dataTypes[col].toLowerCase())) {
        console.log(`타임스탬프 또는 날짜 필드 발견: ${col} (${dataTypes[col]})`);
        dateField = col;
        break;
      }
    }
    
    // 컬럼명 기반으로 날짜 필드 검색 (데이터 타입 기반 검색 실패시)
    if (!dateField) {
      for (const field of possibleDateFields) {
        if (columns.includes(field)) {
          dateField = field;
          break;
        }
      }
    }
    
    console.log(`rfp 테이블 날짜 필드: ${dateField || '없음'}`);
    
    // 실제 rfp 테이블 구조에 맞는 컬럼 설정
    const requiredColumns = ['rfp_seq', 'user_id']; // 반드시 필요한 컬럼
    const optionalColumns = ['pro_name', 'pro_period', 'pro_budget', 'pro_service', 'pro_agency']; // 있으면 사용할 컬럼
    
    // 실제로 존재하는 컬럼만 선택
    let selectedColumns = requiredColumns.filter(col => columns.includes(col));
    
    // 선택적 컬럼 중 존재하는 것만 추가
    optionalColumns.forEach(col => {
      if (columns.includes(col)) {
        selectedColumns.push(col);
      }
    });
    
    // 날짜 필드가 있으면 추가
    if (dateField && !selectedColumns.includes(dateField)) {
      selectedColumns.push(dateField);
    }
    
    console.log('선택된 rfp 컬럼:', selectedColumns);
    
    if (selectedColumns.length === 0) {
      throw new Error('유효한 rfp 컬럼이 없습니다.');
    }
    
    const selectStatement = selectedColumns.join(', ');
    
    // 추가: 실제 생성일/업데이트일이 없을 경우 rfp_seq로 상대적인 생성 순서 판단
    // PostgreSQL 특성상 일반적으로 시퀀스는 생성 순서를 반영함
    const orderByClause = dateField ? `ORDER BY ${dateField} DESC` : `ORDER BY rfp_seq DESC`;
    
    const result = await safeDbAccess(
      async () => {
        // 기존 쿼리에 ORDER BY 절 추가
        const queryResult = await pool.query(
          `SELECT ${selectStatement} FROM rfp ${orderByClause}`
        );
        
        console.log(`조회된 프로젝트 수: ${queryResult.rows.length}`);
        
        // 최초/최신 프로젝트 ID 확인 (생성 일자 추정용)
        const allIds = queryResult.rows.map(p => parseInt(p.rfp_seq) || 0);
        const minId = Math.min(...allIds);
        const maxId = Math.max(...allIds);
        const idRange = maxId - minId || 1;
        
        console.log(`프로젝트 ID 범위: ${minId} ~ ${maxId}`);
        
        // 결과에 직접 사용자 ID 연결
        return queryResult.rows.map(project => {
          // 프로젝트 ID
          const projectId = parseInt(project.rfp_seq) || 0;
          
          // API 응답 구조에 맞게 변환
          const result = {
            id: project.rfp_seq,
            user_id: project.user_id,
            status: '정상',
            owner_id: project.user_id // 직접 사용자 ID 추가
          };
          
          // 날짜 처리
          // 1. 실제 날짜 필드 있으면 사용
          if (dateField && project[dateField] && isValidDate(project[dateField])) {
            try {
              result.created_at = new Date(project[dateField]).toISOString();
            } catch (e) {
              console.error(`날짜 변환 오류 (${dateField}): ${e.message}`);
              // 날짜 변환 오류 시에는 null로 설정
              result.created_at = null;
            }
          } 
          // 2. 날짜 필드 없거나 유효하지 않으면 null로 설정 (클라이언트 측에서 처리)
          else {
            result.created_at = null;
          }
          
          // 프로젝트 이름 설정
          if (project.pro_name) {
            result.name = project.pro_name;
          } else {
            result.name = `프로젝트 ${project.rfp_seq}`;
          }
          
          // 옵션 필드 추가
          if (project.pro_budget) result.budget = project.pro_budget;
          if (project.pro_period) result.period = project.pro_period;
          if (project.pro_service) result.service = project.pro_service;
          if (project.pro_agency) result.agency = project.pro_agency;
          
          // 소유자 정보 간소화 - ID만 직접 표시
          try {
            const userId = project.user_id;
            
            // 소유자 정보를 직접 표시
            result.owner = {
              id: userId,
              name: userId // ID를 이름으로 직접 표시
            };
            
            // 타입 표시 (선택 사항)
            if (String(userId).length > 30) {
              result.owner_type = '카카오';
            } else if (/^\d+$/.test(String(userId))) {
              result.owner_type = '네이버';
            } else if (String(userId).includes('@')) {
              result.owner_type = '이메일';
            } else {
              result.owner_type = '일반';
            }
            
          } catch (error) {
            console.error('소유자 정보 설정 중 오류:', error.message);
            result.owner = {
              id: project.user_id || '알 수 없음',
              name: project.user_id || '알 수 없음'
            };
          }
          
          return result;
        });
      },
      mockData.projects
    );
    
    console.log('프로젝트 목록 조회 성공:', result.length);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('프로젝트 목록 조회 오류:', error);
    
    // 개발 환경에서는 모의 데이터 반환
    if (isDevelopment) {
      return res.json({
        success: true,
        data: mockData.projects
      });
    }
    
    res.status(500).json({
      success: false,
      message: '프로젝트 목록을 불러오는 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 날짜 유효성 검사 도우미 함수 - 강화된 버전
function isValidDate(date) {
  if (!date) return false;
  
  // 문자열이 아닌 경우 문자열로 변환 시도
  if (typeof date !== 'string') {
    try {
      date = date.toISOString();
    } catch (e) {
      try {
        date = String(date);
      } catch (e) {
        return false;
      }
    }
  }
  
  // Unix Epoch 시간 (1970년 1월 1일) 확인
  if (date === '1970-01-01T00:00:00.000Z' || date.startsWith('1970-01-01')) {
    console.log('Unix Epoch 시간(1970-01-01) 감지됨, 유효하지 않은 날짜로 처리');
    return false;
  }
  
  // 날짜 파싱 시도
  const timestamp = Date.parse(date);
  if (isNaN(timestamp)) return false;
  
  // 유효 범위 검사 (2000년 이후 ~ 현재까지)
  const dateObj = new Date(timestamp);
  const currentYear = new Date().getFullYear();
  
  // 2000년 이전이거나 미래 날짜는 유효하지 않음
  if (dateObj.getFullYear() < 2000 || dateObj.getFullYear() > currentYear) {
    console.log(`유효하지 않은 연도: ${dateObj.getFullYear()}, date: ${date}`);
    return false;
  }
  
  return true;
}

// 시스템 통계 조회 API
router.get('/stats', authenticateAdmin, async (req, res) => {
  try {
    console.log('통계 정보 요청 받음');
    
    // 개발 환경에서 모의 데이터 사용 옵션
    if (isDevelopment && process.env.USE_MOCK_DATA === 'true') {
      console.log('모의 통계 데이터 제공 (환경 변수 설정)');
      return res.json({
        success: true,
        data: mockData.stats
      });
    }
    
    // 테이블 존재 여부 확인
    const usersTableExists = await checkTableExists('users');
    const userInfoTableExists = await checkTableExists('user_info');
    const rfpTableExists = await checkTableExists('rfp');
    
    // 모의 데이터 대체
    if (!usersTableExists && !userInfoTableExists && !rfpTableExists) {
      console.log('관련 테이블이 존재하지 않아 모의 데이터 사용');
      return res.json({
        success: true,
        data: mockData.stats
      });
    }
    
    // 현재 날짜 정보
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    
    // 통계 데이터 초기화
    let stats = {
      userCount: 0,
      projectCount: 0,
      todayNewUsers: 0,
      monthlyNewUsers: 0,
      recentUsers: []
    };
    
    // 사용자 통계 수집
    let allUsers = [];
      let userIds = new Set();
    
    // 관리자 계정은 제외하고 user_info 테이블에서만 일반 사용자 통계 수집
      if (userInfoTableExists) {
      try {
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
        } catch (err) {
          console.error('컬럼 정보 조회 오류:', err);
        }
        
        // 일반 사용자 조회 (created_at 컬럼이 있으면 포함)
        const userInfoQuery = hasCreatedAtColumn 
          ? `SELECT user_id, user_email, user_phone, created_at FROM user_info WHERE user_id IS NOT NULL`
          : `SELECT user_id, user_email, user_phone FROM user_info WHERE user_id IS NOT NULL`;
        
        const userInfoResult = await pool.query(userInfoQuery);
        
        // user_info 테이블의 사용자 처리 (일반 사용자)
        for (const info of userInfoResult.rows) {
          // 소셜 로그인 판별 
          const userId = String(info.user_id);
          
          // 연락처 유무로 먼저 판별 (연락처가 없으면 소셜 로그인)
          const hasPhoneNumber = info.user_phone && info.user_phone.trim().length > 0;
          let loginType = '일반';
          
          if (!hasPhoneNumber) {
            // 소셜 로그인 판별 - 네이버는 특수문자(-,_) 포함, 카카오는 숫자로만 구성
            
            // 네이버 ID 확인 - 특수문자(-,_) 포함
            if (userId.includes('-') || userId.includes('_')) {
              loginType = '네이버';
              console.log(`통계: 특수문자 포함 ID로 네이버 로그인 판별: ${userId}`);
            }
            // 카카오 ID 확인 - 숫자로만 구성
            else if (/^\d+$/.test(userId)) {
              loginType = '카카오';
              console.log(`통계: 숫자 ID로 카카오 로그인 판별: ${userId}`);
            } 
            else {
              // 기타 형태의 ID는 일반 소셜 로그인
              loginType = '소셜';
              console.log(`통계: 기타 형태의 소셜 로그인: ${userId}`);
            }
          } else {
            console.log(`통계: 연락처 있음, 일반 로그인으로 판별: ${userId}`);
          }
          
          // 생성일 처리 - created_at 필드가 없으면 2025년 1월 1일로 설정
          let createdAt;
          
          if (hasCreatedAtColumn && info.created_at) {
            // created_at 필드가 있으면 그대로 사용
            createdAt = new Date(info.created_at);
            console.log(`통계: 사용자 ${userId}의 created_at 필드 값: ${info.created_at}, 파싱 결과: ${createdAt.toISOString()}`);
          } else {
            // created_at 필드가 없으면 2025년 1월 1일로 설정
            createdAt = new Date(2025, 0, 1);
            console.log(`통계: 사용자 ${userId}의 created_at 필드 없음, 2025년 1월 1일로 설정: ${createdAt.toISOString()}`);
          }
          
            allUsers.push({
            id: info.user_id,
            username: info.user_email 
              ? info.user_email.split('@')[0] 
              : `사용자 ${userId.substring(0, 8)}...`,
            email: info.user_email || '-',
            created_at: createdAt,
            login_type: loginType.toLowerCase()
          });
          
          userIds.add(info.user_id);
          
          // 오늘/이번달 가입자 카운트
          if (createdAt >= today) {
            stats.todayNewUsers++;
          }
          if (createdAt >= monthStart) {
            stats.monthlyNewUsers++;
          }
        }
        
        console.log(`user_info 테이블에서 ${userInfoResult.rows.length}개 행 처리됨`);
      } catch (error) {
        console.error('일반 사용자 통계 수집 오류:', error);
      }
    }
    
    // 총 사용자 수 설정
    stats.userCount = allUsers.length;
    
    // 생성일 기준 정렬 - Date 객체를 ISO 문자열로 변환
      allUsers.sort((a, b) => {
      return b.created_at - a.created_at;
    });
    
    // Date 객체를 ISO 문자열로 변환
    allUsers.forEach(user => {
      if (user.created_at instanceof Date) {
        user.created_at = user.created_at.toISOString();
        console.log(`통계: 사용자 ${user.id}의 최종 생성일: ${user.created_at}`);
      }
    });
    
    // 최근 가입자 - 최대 10명
    stats.recentUsers = allUsers.slice(0, 10);
    
    // 프로젝트 통계 수집
    if (rfpTableExists) {
      try {
        // 총 프로젝트 수
        const projectCountQuery = 'SELECT COUNT(*) as count FROM rfp';
        const projectCountResult = await pool.query(projectCountQuery);
        stats.projectCount = parseInt(projectCountResult.rows[0]?.count || 0);
    } catch (error) {
        console.error('프로젝트 통계 수집 오류:', error);
      }
    }
    
    console.log('통계 데이터 반환:', stats);
    
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('통계 정보 조회 오류:', error);
    
    // 개발 환경에서는 모의 데이터 반환
    if (isDevelopment) {
      return res.json({
        success: true,
        data: mockData.stats
      });
    }
    
    res.status(500).json({
      success: false,
      message: '통계 정보를 불러오는 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 사용자 삭제 API
router.delete('/users/:userId', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`사용자 삭제 요청: ${userId}`);
    
    // 개발 환경에서 모의 데이터 사용 중일 때
    if (isDevelopment && (!pool || process.env.USE_MOCK_DATA === 'true')) {
      console.log('모의 사용자 삭제 처리');
      return res.json({
        success: true,
        message: '사용자가 성공적으로 삭제되었습니다.'
      });
    }
    
    // 실제 사용자 ID 찾기 (로그인 유형인 경우)
    let actualUserId = userId;
    const loginTypes = ['카카오', '네이버', '이메일', '일반'];
    
    try {
      if (loginTypes.includes(userId)) {
        // 해당 로그인 유형의 첫 번째 사용자 찾기
        let matchedUserId = null;
        
        // user_info 테이블에서 확인
        const userInfoResult = await pool.query(
          `SELECT user_id, user_phone FROM user_info`
        );
        
        for (const row of userInfoResult.rows) {
          const id = String(row.user_id);
          const hasPhoneNumber = row.user_phone && row.user_phone.trim().length > 0;
          
          if (userId === '카카오' && !hasPhoneNumber && /^\d+$/.test(id)) {
            matchedUserId = id;
            break;
          } else if (userId === '네이버' && !hasPhoneNumber && (id.includes('-') || id.includes('_'))) {
            matchedUserId = id;
            break;
          } else if (userId === '이메일' && id.includes('@')) {
            matchedUserId = id;
            break;
          } else if (userId === '일반' && hasPhoneNumber && !id.includes('@') && 
                    !(id.includes('-') || id.includes('_')) && !/^\d+$/.test(id)) {
            matchedUserId = id;
            break;
          }
        }
        
        if (matchedUserId) {
          actualUserId = matchedUserId;
          console.log(`로그인 유형 "${userId}"에 맞는 사용자 ID 찾음: ${actualUserId}`);
        } else {
          throw new Error(`로그인 유형 "${userId}"에 해당하는 사용자를 찾을 수 없습니다.`);
        }
      }
    } catch (error) {
      console.error('로그인 유형 기반 사용자 검색 오류:', error);
      // 원래 ID로 계속 진행
    }
    
    // 수정: ID가 숫자인지 문자열인지 확인하여 적절한 쿼리 사용
    if (/^\d+$/.test(actualUserId)) {
      // 숫자 ID인 경우 - users 테이블에서 직접 삭제
      await safeDbAccess(
        async () => {
          await pool.query('DELETE FROM users WHERE id = $1', [actualUserId]);
          return true;
        },
        true
      );
    } else {
      // 문자열 ID인 경우 - 각 테이블에서 관련 데이터 삭제
      
      // 1. user_info 테이블 체크 및 삭제
      const userInfoTableExists = await checkTableExists('user_info');
      if (userInfoTableExists) {
        await pool.query('DELETE FROM user_info WHERE user_id = $1', [actualUserId]);
        console.log(`user_info 테이블에서 사용자 ID ${actualUserId} 삭제 시도`);
      }
      
      // 2. session 테이블에서 관련 세션 제거 (복잡하므로 스킵)
      
      // 3. rfp에서 해당 사용자의 프로젝트 삭제 또는 처리
      // 주의: 실제 환경에서는 삭제보다 소유권 이전이나 플래그 처리가 적절할 수 있음
      // 여기서는 삭제하지 않고 로그만 남김
      console.log(`사용자 ID ${actualUserId}와 관련된 프로젝트는 유지됨`);
    }
    
    res.json({
      success: true,
      message: '사용자가 성공적으로 삭제되었습니다.'
    });
  } catch (error) {
    console.error('사용자 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '사용자 삭제 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 관리자 인증 테스트 API
router.get('/check', authenticateAdmin, (req, res) => {
  res.json({
    success: true,
    message: '관리자 인증 성공',
    admin: true
  });
});

// 세션 확인용 /protected 추가
router.get('/protected', (req, res) => {
  console.log('Admin protected 경로 접근');
  res.json({ 
    isLoggedIn: true,
    message: '관리자 보호 경로 접근 성공'
  });
});

export default router;
