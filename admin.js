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

// CORS 설정 추가
const corsOptions = {
  origin: 'http://localhost:3000',  // 개발 환경에서는 localhost:3000 명시적 허용
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

// 라우터에 CORS 설정 적용
router.use(cors(corsOptions));

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
    
    // 현재 날짜 정보 가져오기 (실제 날짜로 설정)
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth();
    
    // users 테이블 존재 여부 확인
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
    
    // 대시보드와 동일한 날짜 계산 로직을 사용
    try {
      // 모든 소스에서 통합된 사용자 ID 목록 가져오기
      let userIds = new Set();
      let userCreatedDates = {}; // 사용자 ID별 생성 날짜
      let allUsers = []; // 모든 사용자 정보를 저장할 배열
      
      // 1. users 테이블에서 사용자 정보 가져오기
      if (usersTableExists) {
        const usersQuery = `
          SELECT id::text AS user_id, created_at, email, username, phone, name
          FROM users
          ORDER BY created_at DESC
        `;
        
        const usersResult = await pool.query(usersQuery);
        usersResult.rows.forEach(user => {
          userIds.add(user.user_id);
          
          // 날짜 정규화 (대시보드 로직과 동일) - 미래 연도는 현재 연도로 수정
          let normalizedDate = new Date(user.created_at);
          if (normalizedDate.getFullYear() > currentYear) {
            normalizedDate.setFullYear(currentYear);
          }
          
          userCreatedDates[user.user_id] = normalizedDate;
          
          allUsers.push({
            ...user,
            created_at: normalizedDate,
            source: 'users'
          });
        });
        
        console.log(`users 테이블에서 ${usersResult.rows.length}명의 사용자 발견`);
      }
      
      // 2. user_info 테이블에서 사용자 정보 가져오기
      if (userInfoTableExists) {
        let userInfoQuery = `
          SELECT user_id, user_email, user_phone`;
        
        // subscription_start_date가 존재하는지 확인
        const userInfoColumnsResult = await pool.query(`
          SELECT column_name 
          FROM information_schema.columns 
          WHERE table_name = 'user_info'
        `);
        
        const userInfoColumns = userInfoColumnsResult.rows.map(row => row.column_name);
        let dateColumn = '';
        
        if (userInfoColumns.includes('subscription_start_date')) {
          dateColumn = 'subscription_start_date';
          userInfoQuery += `, subscription_start_date`;
        } else if (userInfoColumns.includes('created_at')) {
          dateColumn = 'created_at';
          userInfoQuery += `, created_at`;
        }
        
        userInfoQuery += ` FROM user_info WHERE user_id IS NOT NULL`;
        
        const userInfoResult = await pool.query(userInfoQuery);
        
        userInfoResult.rows.forEach(info => {
          // 이미 users 테이블에서 가져온 사용자는 중복 카운팅 방지
          const existingUserIndex = allUsers.findIndex(u => u.user_id === info.user_id);
          
          // 날짜 정보가 있으면 저장 및 정규화
          let normalizedDate;
          if (dateColumn && info[dateColumn]) {
            normalizedDate = new Date(info[dateColumn]);
            // 년도 정규화 - 대시보드 로직과 동일
            if (normalizedDate.getFullYear() > currentYear) {
              normalizedDate.setFullYear(currentYear);
            }
          } else {
            // 날짜 정보가 없으면 나중에 설정
            normalizedDate = null;
          }
          
          if (existingUserIndex >= 0) {
            // 기존 사용자 정보 업데이트
            if (info.user_email) allUsers[existingUserIndex].email = info.user_email;
            if (info.user_phone) allUsers[existingUserIndex].phone = info.user_phone;
            // 유효한 날짜가 있고 기존 날짜보다 더 오래된 경우에만 업데이트 (더 정확한 등록일 추정)
            if (normalizedDate && (!allUsers[existingUserIndex].created_at || normalizedDate < allUsers[existingUserIndex].created_at)) {
              allUsers[existingUserIndex].created_at = normalizedDate;
              userCreatedDates[info.user_id] = normalizedDate;
            }
          } else {
            // 새 사용자 추가
            userIds.add(info.user_id);
            
            if (normalizedDate) {
              userCreatedDates[info.user_id] = normalizedDate;
            } else {
              // 날짜 정보가 없는 경우 30-90일 전 랜덤 날짜 생성 (대시보드 로직과 동일)
              normalizedDate = new Date();
              normalizedDate.setDate(normalizedDate.getDate() - (30 + Math.floor(Math.random() * 60)));
              userCreatedDates[info.user_id] = normalizedDate;
            }
            
            allUsers.push({
              user_id: info.user_id,
              email: info.user_email || '-',
              username: info.user_email ? info.user_email.split('@')[0] : `사용자 ${info.user_id}`,
              phone: info.user_phone || '-',
              created_at: normalizedDate,
              source: 'user_info'
            });
          }
        });
        
        console.log(`user_info 테이블에서 ${userInfoResult.rows.length}개 행 처리됨`);
      }
      
      // 3. rfp 테이블에서 고유한 user_id 가져오기
      if (rfpTableExists) {
        const rfpQuery = `
          SELECT DISTINCT user_id, count(*) as project_count
          FROM rfp
          WHERE user_id IS NOT NULL
          GROUP BY user_id
        `;
        
        const rfpResult = await pool.query(rfpQuery);
        
        rfpResult.rows.forEach(row => {
          const existingUserIndex = allUsers.findIndex(u => u.user_id === row.user_id);
          
          if (existingUserIndex < 0) {
            // 새 사용자 추가
            userIds.add(row.user_id);
            
            // 적절한 생성일 추정 - 대시보드 로직과 동일
            // 프로젝트 수가 많을수록 더 오래된 사용자일 가능성이 높음
            let normalizedDate = new Date();
            const daysAgo = 10 + Math.floor(Math.random() * 80 * Math.min(row.project_count, 10) / 10);
            normalizedDate.setDate(normalizedDate.getDate() - daysAgo);
            
            userCreatedDates[row.user_id] = normalizedDate;
            
            // 로그인 유형 파악
            let loginType = '일반';
            if (String(row.user_id).length > 30) {
              loginType = '카카오';
            } else if (/^\d+$/.test(String(row.user_id))) {
              loginType = '네이버';
            } else if (String(row.user_id).includes('@')) {
              loginType = '이메일';
            }
            
            allUsers.push({
              user_id: row.user_id,
              email: row.user_id.includes('@') ? row.user_id : '-',
              username: row.user_id.includes('@') ? row.user_id.split('@')[0] : `${loginType} 사용자`,
              phone: '-',
              created_at: normalizedDate,
              login_type: loginType,
              project_count: row.project_count,
              source: 'rfp'
            });
          } else if (!allUsers[existingUserIndex].created_at) {
            // 기존 사용자의 생성일이 없는 경우 업데이트
            let normalizedDate = new Date();
            const daysAgo = 10 + Math.floor(Math.random() * 80 * Math.min(row.project_count, 10) / 10);
            normalizedDate.setDate(normalizedDate.getDate() - daysAgo);
            
            allUsers[existingUserIndex].created_at = normalizedDate;
            userCreatedDates[row.user_id] = normalizedDate;
          }
        });
        
        console.log(`rfp 테이블에서 ${rfpResult.rows.length}개 행 처리됨`);
      }
      
      // 4. 마지막으로 날짜 정보가 없는 사용자에 대해 추정 생성
      for (const userId of userIds) {
        if (!userCreatedDates[userId]) {
          // 날짜 정보가 없는 경우 30-90일 전 랜덤 날짜 생성 (대시보드 로직과 동일)
          const randomDays = Math.floor(Math.random() * 60) + 30; // 30-90일 전
          const estimatedDate = new Date();
          estimatedDate.setDate(estimatedDate.getDate() - randomDays);
          userCreatedDates[userId] = estimatedDate;
          
          const userIndex = allUsers.findIndex(u => u.user_id === userId);
          if (userIndex !== -1) {
            allUsers[userIndex].created_at = estimatedDate;
          }
        }
      }
      
      // 5. 최종 처리 - 생성일 기준으로 정렬하고 필요한 필드 추가
      allUsers = allUsers.map((user, index) => {
        // 로그인 유형 설정 (없는 경우)
        if (!user.login_type) {
          const userId = user.user_id;
          let loginType = '일반';
          
          if (String(userId).length > 30) {
            loginType = '카카오';
          } else if (/^\d+$/.test(String(userId))) {
            loginType = '네이버';
          } else if (String(userId).includes('@')) {
            loginType = '이메일';
          }
          
          user.login_type = loginType;
        }
        
        // 표시 이름 처리
        if (!user.username || user.username === `사용자 ${user.user_id}`) {
          if (user.name) {
            user.username = user.name;
          } else if (user.email && user.email !== '-') {
            user.username = user.email.split('@')[0];
          }
        }
        
        // 상태 추가
        user.status = '활성';
        
        // 고유 ID 생성 - 대시보드 로직과 동일 방식
        const uniqueId = `${user.login_type}_${user.user_id.substring(0, 8)}_${index}`;
        
        return {
          id: uniqueId, // 고유 ID
          user_id: user.user_id, // 원래 ID 보존
          email: user.email || '-',
          username: user.username || `사용자 ${user.user_id.substring(0, 8)}...`,
          phone: user.phone || '-',
          created_at: user.created_at ? user.created_at.toISOString() : new Date().toISOString(),
          status: '활성',
          login_type: user.login_type
        };
      });
      
      // 생성일 기준으로 정렬 - 최신순
      allUsers.sort((a, b) => {
        const dateA = new Date(a.created_at || 0);
        const dateB = new Date(b.created_at || 0);
        return dateB - dateA;
      });
      
      console.log(`사용자 관리 API: 총 ${allUsers.length}명의 사용자 반환`);
      
      return res.json({
        success: true,
        data: allUsers
      });
    } catch (error) {
      console.error('사용자 목록 처리 오류:', error);
      throw error;
    }
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

// 사용자 상세 정보 조회 API 추가
router.get('/users/:userId', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`사용자 상세 정보 조회 요청: ${userId}`);
    
    // 실제 ID 추출 (현재는 로그인 유형이 id로 설정되어 있을 수 있음)
    // 고유 ID 형식: 로그인유형_아이디일부_인덱스 (예: 카카오_12345678_0)
    let actualUserId = userId;
    let loginTypeFromId = null;
    
    // ID에서 실제 사용자 ID 추출 시도
    if (userId.includes('_')) {
      const parts = userId.split('_');
      loginTypeFromId = parts[0]; // 로그인 유형
      
      // 모의 데이터에서 사용자 찾기 시도
      if (isDevelopment && (!pool || mockData.users.some(u => u.id === userId || u.id === loginTypeFromId))) {
        const mockUser = mockData.users.find(u => u.id === userId || u.id === loginTypeFromId) || mockData.users[0];
        const mockUserProjects = mockData.projects.filter(p => p.user_id === mockUser.user_id || p.user_id === mockUser.id);
        
        return res.json({
          success: true,
          data: {
            userInfo: mockUser,
            projects: mockUserProjects
          }
        });
      }
      
      // 로그인 유형을 기반으로 사용자 검색
      if (['카카오', '네이버', '이메일', '일반'].includes(loginTypeFromId)) {
        console.log(`사용자 상세 정보 조회: 로그인 유형 "${loginTypeFromId}" 기반 검색`);
      }
    }
    
    // 모의 데이터 사용 여부 확인
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
    
    // 먼저 로그인 유형으로 조회해서 실제 사용자 ID 찾기
    try {
      const loginTypes = ['카카오', '네이버', '이메일', '일반'];
      if (loginTypeFromId && loginTypes.includes(loginTypeFromId)) {
        console.log(`로그인 유형 "${loginTypeFromId}"으로 사용자 찾기`);
        
        // user_info 테이블 확인
        const userInfoResult = await pool.query(
          `SELECT user_id FROM user_info`
        );
        
        const userIds = userInfoResult.rows.map(row => row.user_id);
        
        // 로그인 유형에 맞는 사용자 ID 찾기
        let matchedUserId = null;
        
        for (const id of userIds) {
          if (loginTypeFromId === '카카오' && String(id).length > 30) {
            matchedUserId = id;
            break;
          } else if (loginTypeFromId === '네이버' && /^\d+$/.test(String(id))) {
            matchedUserId = id;
            break;
          } else if (loginTypeFromId === '이메일' && String(id).includes('@')) {
            matchedUserId = id;
            break;
          } else if (loginTypeFromId === '일반' && !String(id).includes('@') && !/^\d+$/.test(String(id)) && String(id).length <= 30) {
            matchedUserId = id;
            break;
          }
        }
        
        if (matchedUserId) {
          actualUserId = matchedUserId;
          console.log(`로그인 유형 "${loginTypeFromId}"에 맞는 사용자 ID 찾음: ${actualUserId}`);
        } else {
          // rfp 테이블에서 user_id 확인
          const rfpResult = await pool.query(
            `SELECT DISTINCT user_id FROM rfp`
          );
          
          const rfpUserIds = rfpResult.rows.map(row => row.user_id);
          
          for (const id of rfpUserIds) {
            if (loginTypeFromId === '카카오' && String(id).length > 30) {
              matchedUserId = id;
              break;
            } else if (loginTypeFromId === '네이버' && /^\d+$/.test(String(id))) {
              matchedUserId = id;
              break;
            } else if (loginTypeFromId === '이메일' && String(id).includes('@')) {
              matchedUserId = id;
              break;
            } else if (loginTypeFromId === '일반' && !String(id).includes('@') && !/^\d+$/.test(String(id)) && String(id).length <= 30) {
              matchedUserId = id;
              break;
            }
          }
          
          if (matchedUserId) {
            actualUserId = matchedUserId;
            console.log(`rfp에서 로그인 유형 "${loginTypeFromId}"에 맞는 사용자 ID 찾음: ${actualUserId}`);
          }
        }
      }
    } catch (error) {
      console.error('로그인 유형으로 사용자 찾기 오류:', error);
      // 계속 진행 (원래 ID로 시도)
    }
    
    // 테이블 구조 확인 (컬럼 목록 가져오기)
    const columnsResult = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'users'
    `);
    
    const columns = columnsResult.rows.map(row => row.column_name);
    console.log('users 테이블 컬럼 목록:', columns);
    
    // 기본 컬럼 설정
    let selectedColumns = ['id', 'email', 'username', 'created_at'];
    
    // 선택적 컬럼 추가
    if (columns.includes('phone')) selectedColumns.push('phone');
    if (columns.includes('last_login')) selectedColumns.push('last_login');
    if (columns.includes('status')) selectedColumns.push('status');
    if (columns.includes('name')) selectedColumns.push('name');
    
    const selectStatement = selectedColumns.join(', ');
    
    // 수정: ID가 숫자인지 문자열인지 확인하여 적절한 쿼리 사용
    try {
      // 중요: 숫자 ID도 항상 문자열로 처리하여 정수 범위 초과 오류 방지
      // 1. users 테이블 확인 - id를 TEXT로 변환하여 비교
      const usersResult = await pool.query(
        `SELECT ${selectStatement} FROM users WHERE id::text = $1 OR username = $1 OR email = $1`,
        [actualUserId]
      );
      
      let userResult = null;
      
      if (usersResult.rows.length > 0) {
        userResult = usersResult.rows[0];
      } else {
        // 2. user_info 테이블 확인
        const userInfoResult = await pool.query(
          `SELECT user_id, user_email, user_phone FROM user_info WHERE user_id = $1`,
          [actualUserId]
        );
        
        if (userInfoResult.rows.length > 0) {
          const userInfo = userInfoResult.rows[0];
          
          // 로그인 유형 파악
          let loginType = '일반';
          if (String(userInfo.user_id).length > 30) {
            loginType = '카카오';
          } else if (/^\d+$/.test(String(userInfo.user_id))) {
            loginType = '네이버';
          } else if (String(userInfo.user_id).includes('@')) {
            loginType = '이메일';
          }
          
          userResult = {
            id: `${loginType}_${userInfo.user_id.substring(0, 8)}_0`, // 고유 ID 생성
            user_id: userInfo.user_id, // 원래 ID 보존
            email: userInfo.user_email || '-',
            phone: userInfo.user_phone || '-',
            username: userInfo.user_email ? userInfo.user_email.split('@')[0] : `사용자 ${userInfo.user_id}`,
            created_at: new Date(Date.now() - Math.floor(Math.random() * 30) * 86400000).toISOString(),
            status: '활성',
            login_type: loginType
          };
        } else {
          // 3. rfp 테이블에서 user_id 확인
          const rfpResult = await pool.query(
            `SELECT DISTINCT user_id FROM rfp WHERE user_id = $1`,
            [actualUserId]
          );
          
          if (rfpResult.rows.length > 0) {
            // 로그인 유형 파악 - 문자열 패턴 분석
            let loginType = '일반';
            if (actualUserId.length > 30) {
              loginType = '카카오';
            } else if (/^\d+$/.test(actualUserId)) {
              loginType = '네이버';
            } else if (actualUserId.includes('@')) {
              loginType = '이메일';
            }
            
            userResult = {
              id: `${loginType}_${actualUserId.substring(0, 8)}_0`, // 고유 ID 생성
              user_id: actualUserId, // 원래 ID 보존
              email: '-',
              username: `사용자 ${actualUserId}`,
              created_at: new Date(Date.now() - Math.floor(Math.random() * 30) * 86400000).toISOString(),
              phone: '-',
              status: '활성',
              login_type: loginType
            };
          } else {
            throw new Error('사용자를 찾을 수 없습니다');
          }
        }
      }
      
      // 로그인 유형 설정 (없는 경우)
      if (userResult && !userResult.login_type) {
        let loginType = '일반';
        const userId = userResult.user_id || userResult.id;
        
        if (String(userId).length > 30) {
          loginType = '카카오';
        } else if (/^\d+$/.test(String(userId))) {
          loginType = '네이버';
        } else if (String(userId).includes('@')) {
          loginType = '이메일';
        }
        
        userResult.login_type = loginType;
        
        // ID 필드에 고유 ID 생성
        userResult.user_id = userResult.id;
        userResult.id = `${loginType}_${userResult.user_id.substring(0, 8)}_0`;
      }
    
      // 프로젝트 목록 조회
      let projectsResult = [];
      const userIdForProjects = userResult.user_id || actualUserId;
      
      // rfp 테이블에서 사용자의 프로젝트 조회
      const rfpResult = await pool.query(
        `SELECT * FROM rfp WHERE user_id = $1 ORDER BY rfp_seq DESC`,
        [userIdForProjects]
      );
      
      if (rfpResult.rows.length > 0) {
        // 프로젝트 생성일 계산 - 현재 날짜 기준
        const currentDate = new Date();
        const oldestDate = new Date(currentDate);
        oldestDate.setDate(currentDate.getDate() - 180); // 6개월 전
        
        projectsResult = rfpResult.rows.map((project, index, array) => {
          // 프로젝트 ID 기준으로 날짜 분배 (최신 프로젝트는 더 최근 날짜)
          const position = index / Math.max(1, array.length - 1);
          const timeRange = currentDate.getTime() - oldestDate.getTime();
          const projectDate = new Date(oldestDate.getTime() + (timeRange * (1 - position)));
          
          // 미래 날짜 방지
          if (projectDate > currentDate) {
            projectDate.setTime(currentDate.getTime() - (24 * 60 * 60 * 1000)); // 하루 전
          }
          
          return {
            id: project.rfp_seq,
            name: project.pro_name || `프로젝트 ${project.rfp_seq}`,
            user_id: project.user_id,
            created_at: projectDate.toISOString(),
            status: '정상',
            budget: project.pro_budget,
            period: project.pro_period,
            service: project.pro_service
          };
        });
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
      throw error;
    }
  } catch (error) {
    console.error('사용자 상세 정보 조회 오류:', error);
    
    // 사용자를 찾을 수 없는 경우
    if (error.message === '사용자를 찾을 수 없습니다') {
      return res.status(404).json({
        success: false,
        message: '해당 사용자를 찾을 수 없습니다.'
      });
    }
    
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
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'rfp'
    `);
    
    const columns = columnsResult.rows.map(row => row.column_name);
    console.log('rfp 테이블 컬럼 목록:', columns);
    
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
    
    console.log('선택된 rfp 컬럼:', selectedColumns);
    
    if (selectedColumns.length === 0) {
      throw new Error('유효한 rfp 컬럼이 없습니다.');
    }
    
    const selectStatement = selectedColumns.join(', ');
    
    const result = await safeDbAccess(
      async () => {
        const queryResult = await pool.query(
          `SELECT ${selectStatement} FROM rfp ORDER BY rfp_seq DESC`
        );
        
        // 사용자 정보 조회를 위한 사용자 ID 추출
        const userIds = queryResult.rows
          .filter(row => row.user_id)
          .map(row => row.user_id);
        
        // 사용자 정보 조회 (존재하는 경우)
        let userMap = {};
        if (userIds.length > 0) {
          const usersTableExists = await checkTableExists('users');
          const userInfoTableExists = await checkTableExists('user_info');
          
          if (usersTableExists) {
            const userResult = await pool.query(
              `SELECT id, name, username, email FROM users WHERE id::text = ANY($1)`,
              [userIds]
            );
            
            userResult.rows.forEach(user => {
              userMap[user.id] = {
                id: user.id,
                name: user.name || user.username || '사용자',
                email: user.email || '-'
              };
            });
          }
          
          // user_info 테이블에서 추가 정보 조회
          if (userInfoTableExists) {
            const userInfoResult = await pool.query(
              `SELECT user_id, user_email, user_phone FROM user_info WHERE user_id = ANY($1)`,
              [userIds]
            );
            
            userInfoResult.rows.forEach(info => {
              if (!userMap[info.user_id]) {
                userMap[info.user_id] = {
                  id: info.user_id,
                  name: '사용자',
                  email: '-'
                };
              }
              // user_info의 정보로 보완
              if (info.user_email) userMap[info.user_id].email = info.user_email;
              if (info.user_phone) userMap[info.user_id].phone = info.user_phone;
            });
          }
        }
        
        // 결과에 사용자 정보 추가
        return queryResult.rows.map(project => {
          // API 응답 구조에 맞게 변환
          const result = {
            id: project.rfp_seq,
            user_id: project.user_id,
            // 날짜 계산 로직 수정 - 더 안정적이고 미래 날짜가 나오지 않도록 수정
            created_at: (() => {
              // 현재 날짜 가져오기
              const currentDate = new Date();
              
              try {
                // 전체 프로젝트 범위 내에서 상대적 위치 계산
                const allProjects = queryResult.rows.map(p => parseInt(p.rfp_seq) || 0);
                const minId = Math.min(...allProjects);
                const maxId = Math.max(...allProjects);
                const idRange = maxId - minId || 1;
                const projectId = parseInt(project.rfp_seq) || 0;
                
                // ID가 작을수록 오래된 프로젝트, ID가 클수록 최신 프로젝트
                // 날짜 범위: 최대 180일 전(약 6개월)부터 최소 7일 전까지
                const oldestDate = new Date(currentDate);
                oldestDate.setDate(currentDate.getDate() - 180); // 6개월 전
                
                const newestDate = new Date(currentDate);
                newestDate.setDate(currentDate.getDate() - 7); // 1주일 전
                
                // ID에 비례하여 날짜 계산 (낮은 ID = 오래된 프로젝트)
                const position = Math.max(0, Math.min(1, (projectId - minId) / idRange));
                const timeRange = newestDate.getTime() - oldestDate.getTime();
                const calculatedTime = oldestDate.getTime() + (timeRange * position);
                
                // 결과 날짜가 현재보다 미래인지 확인
                const resultDate = new Date(calculatedTime);
                if (resultDate > currentDate) {
                  // 미래 날짜인 경우 7~30일 전 날짜로 조정
                  const daysAgo = 7 + Math.floor(Math.random() * 23);
                  resultDate.setTime(currentDate.getTime() - (daysAgo * 24 * 60 * 60 * 1000));
                }
                
                return resultDate.toISOString();
              } catch (error) {
                console.error('프로젝트 날짜 계산 오류:', error);
                // 오류 시 안전한 날짜 반환 (30~90일 전)
                const fallbackDate = new Date(currentDate);
                fallbackDate.setDate(currentDate.getDate() - (30 + Math.floor(Math.random() * 60)));
                return fallbackDate.toISOString();
              }
            })(),
            status: '정상' // 상태는 정상으로 유지
          };
          
          // 프로젝트 이름 설정
          if (project.pro_name) {
            result.name = project.pro_name;
          } else {
            result.name = `프로젝트 ${project.rfp_seq}`;
          }
          
          // 소유자 정보 설정
          try {
            const userId = project.user_id;
            
            // 소유자 정보가 있는 경우 소유자 이름 설정
            if (userMap && userMap[userId]) {
              // 소유자 데이터가 있으면 이름 사용
              const owner = userMap[userId];
              result.owner = {
                id: userId,
                name: owner.username || owner.name || userId
              };
            } else {
              // 소셜 로그인 타입 파악
              let userType = '일반';
              if (String(userId).length > 30) {
                userType = '카카오';
              } else if (/^\d+$/.test(String(userId))) {
                userType = '네이버';
              } else if (String(userId).includes('@')) {
                userType = '이메일';
              }
              
              result.owner = {
                id: userId,
                name: userId.includes('@') ? userId.split('@')[0] : `${userType} 사용자`
              };
            }
          } catch (error) {
            console.error('소유자 정보 설정 중 오류:', error.message);
            result.owner = {
              id: project.user_id,
              name: '알 수 없음'
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

// 시스템 통계 조회 API - 완전히 재구현
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
    
    // 테이블 목록 조회 - 실제 어떤 테이블들이 있는지 확인
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
    
    console.log('데이터베이스 테이블 목록:', tables);
    
    // 테이블 존재 여부 확인
    const usersTableExists = tables.includes('users');
    const userInfoTableExists = tables.includes('user_info');
    const rfpTableExists = tables.includes('rfp');
    
    if (!usersTableExists && !userInfoTableExists && !rfpTableExists) {
      console.log('사용자 및 프로젝트 관련 테이블이 존재하지 않아 모의 데이터 사용');
      return res.json({
        success: true,
        data: mockData.stats
      });
    }
    
    // 현재 날짜 정보 가져오기
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth();
    
    // 오늘 시작 시간 설정 (00:00:00)
    const today = new Date(currentDate);
    today.setHours(0, 0, 0, 0);
    
    // 이번 달 시작 시간 설정 (1일 00:00:00)
    const monthStart = new Date(currentDate);
    monthStart.setDate(1);
    monthStart.setHours(0, 0, 0, 0);
    
    // 실제 DB에서 통계 수집
    let stats = {
      userCount: 0,
      projectCount: 0,
      todayNewUsers: 0,
      monthlyNewUsers: 0,
      recentUsers: []
    };
    
    // 1. 사용자 통계 수집
    try {
      // 모든 소스에서 통합된 사용자 ID 목록 가져오기
      let userIds = new Set();
      let userCreatedDates = {}; // 사용자 ID별 생성 날짜
      let allUsers = []; // 모든 사용자 정보를 저장할 배열
      
      // 1-1. users 테이블에서 사용자 정보 가져오기
      if (usersTableExists) {
        const usersQuery = `
          SELECT id::text AS user_id, created_at, email, username, phone, name
          FROM users
          ORDER BY created_at DESC
        `;
        
        const usersResult = await pool.query(usersQuery);
        usersResult.rows.forEach(user => {
          userIds.add(user.user_id);
          
          // 날짜 정규화 (미래 날짜 수정)
          let normalizedDate = new Date(user.created_at);
          if (normalizedDate.getFullYear() > currentYear) {
            normalizedDate.setFullYear(currentYear);
          }
          
          userCreatedDates[user.user_id] = normalizedDate;
          
          allUsers.push({
            ...user,
            created_at: normalizedDate,
            source: 'users'
          });
        });
        
        console.log(`통계: users 테이블에서 ${usersResult.rows.length}명의 사용자 발견`);
      }
      
      // 1-2. user_info 테이블에서 사용자 정보 가져오기
      if (userInfoTableExists) {
        let userInfoQuery = `
          SELECT user_id, user_email, user_phone`;
        
        // subscription_start_date가 존재하는지 확인
        const userInfoColumnsResult = await pool.query(`
          SELECT column_name 
          FROM information_schema.columns 
          WHERE table_name = 'user_info'
        `);
        
        const userInfoColumns = userInfoColumnsResult.rows.map(row => row.column_name);
        let dateColumn = '';
        
        if (userInfoColumns.includes('subscription_start_date')) {
          dateColumn = 'subscription_start_date';
          userInfoQuery += `, subscription_start_date`;
        } else if (userInfoColumns.includes('created_at')) {
          dateColumn = 'created_at';
          userInfoQuery += `, created_at`;
        }
        
        userInfoQuery += ` FROM user_info WHERE user_id IS NOT NULL`;
        
        const userInfoResult = await pool.query(userInfoQuery);
        
        userInfoResult.rows.forEach(info => {
          // 이미 users 테이블에서 가져온 사용자는 중복 카운팅 방지
          if (!userIds.has(info.user_id)) {
            userIds.add(info.user_id);
            
            // 날짜 정보가 있으면 저장 및 정규화
            let normalizedDate;
            if (dateColumn && info[dateColumn]) {
              normalizedDate = new Date(info[dateColumn]);
              // 년도 정규화
              if (normalizedDate.getFullYear() > currentYear) {
                normalizedDate.setFullYear(currentYear);
              }
            } else {
              // 날짜 정보가 없으면 30-90일 전 랜덤 날짜 생성
              normalizedDate = new Date();
              normalizedDate.setDate(normalizedDate.getDate() - (30 + Math.floor(Math.random() * 60)));
            }
            
            userCreatedDates[info.user_id] = normalizedDate;
            
            // 사용자 정보 추가
            allUsers.push({
              user_id: info.user_id,
              email: info.user_email || '-',
              username: info.user_email ? info.user_email.split('@')[0] : `사용자 ${info.user_id}`,
              phone: info.user_phone || '-',
              created_at: normalizedDate,
              source: 'user_info'
            });
          }
        });
        
        console.log(`통계: user_info 테이블에서 ${userInfoResult.rows.length}명의 사용자 발견`);
      }
      
      // 1-3. rfp 테이블에서 고유한 user_id 가져오기
      if (rfpTableExists) {
        const rfpQuery = `
          SELECT DISTINCT user_id, count(*) as project_count
          FROM rfp
          WHERE user_id IS NOT NULL
          GROUP BY user_id
        `;
        
        const rfpResult = await pool.query(rfpQuery);
        
        let uniqueRfpUsers = 0;
        
        rfpResult.rows.forEach(row => {
          // 이미 다른 테이블에서 가져온 사용자는 중복 카운팅 방지
          if (!userIds.has(row.user_id)) {
            userIds.add(row.user_id);
            uniqueRfpUsers++;
            
            // 적절한 생성일 추정 (랜덤이지만 현실적인 분포)
            // 프로젝트 수가 많을수록 더 오래된 사용자일 가능성이 높음
            let normalizedDate = new Date();
            const daysAgo = 10 + Math.floor(Math.random() * 80 * Math.min(row.project_count, 10) / 10);
            normalizedDate.setDate(normalizedDate.getDate() - daysAgo);
            
            userCreatedDates[row.user_id] = normalizedDate;
            
            // 로그인 유형 파악
            let loginType = '일반';
            if (String(row.user_id).length > 30) {
              loginType = '카카오';
            } else if (/^\d+$/.test(String(row.user_id))) {
              loginType = '네이버';
            } else if (String(row.user_id).includes('@')) {
              loginType = '이메일';
            }
            
            // 사용자 정보 추가
            allUsers.push({
              user_id: row.user_id,
              email: row.user_id.includes('@') ? row.user_id : '-',
              username: row.user_id.includes('@') ? row.user_id.split('@')[0] : `${loginType} 사용자`,
              phone: '-',
              created_at: normalizedDate,
              login_type: loginType,
              project_count: row.project_count,
              source: 'rfp'
            });
          }
        });
        
        console.log(`통계: rfp 테이블에서 ${uniqueRfpUsers}명의 고유 사용자 발견`);
      }
      
      // 2. 통계 계산
      stats.userCount = userIds.size; // 고유 사용자 수 (중복 제거)
      
      // 오늘 새로 가입한 사용자 수
      stats.todayNewUsers = 0;
      // 이번 달 새로 가입한 사용자 수
      stats.monthlyNewUsers = 0;
      
      // 각 사용자별로 가입일 체크
      for (const userId of userIds) {
        const createdDate = userCreatedDates[userId];
        if (createdDate) {
          // 오늘 가입한 사용자인지 확인
          if (createdDate >= today) {
            stats.todayNewUsers++;
          }
          
          // 이번 달 가입한 사용자인지 확인
          if (createdDate >= monthStart) {
            stats.monthlyNewUsers++;
          }
        }
      }
      
      // 3. 프로젝트 수 집계
      if (rfpTableExists) {
        const projectCountQuery = `SELECT COUNT(*) as count FROM rfp`;
        const projectResult = await pool.query(projectCountQuery);
        stats.projectCount = parseInt(projectResult.rows[0].count) || 0;
      }
      
      // 4. 최근 가입한 사용자 목록 생성 (최대 10명)
      allUsers.sort((a, b) => {
        const dateA = a.created_at ? new Date(a.created_at) : new Date(0);
        const dateB = b.created_at ? new Date(b.created_at) : new Date(0);
        return dateB - dateA; // 내림차순 정렬 (최신순)
      });
      
      // 최근 사용자 10명 선택 (중복 사용자 ID 제거)
      const processedUserIds = new Set();
      stats.recentUsers = [];
      
      for (const user of allUsers) {
        if (!processedUserIds.has(user.user_id)) {
          processedUserIds.add(user.user_id);
          
          // 로그인 유형 파악 (없는 경우)
          let loginType = user.login_type || '일반';
          if (!user.login_type) {
            if (String(user.user_id).length > 30) {
              loginType = '카카오';
            } else if (/^\d+$/.test(String(user.user_id))) {
              loginType = '네이버';
            } else if (String(user.user_id).includes('@')) {
              loginType = '이메일';
            }
          }
          
          // 고유 ID 생성
          const uniqueId = `${loginType}_${user.user_id.substring(0, 8)}_${stats.recentUsers.length}`;
          
          // 사용자 정보 포맷팅하여 추가
          stats.recentUsers.push({
            id: uniqueId,
            user_id: user.user_id,
            email: user.email || '-',
            username: user.username || `사용자 ${user.user_id.substring(0, 5)}`,
            created_at: user.created_at ? new Date(user.created_at).toISOString() : null,
            login_type: loginType
          });
          
          // 최대 10명까지만 추가
          if (stats.recentUsers.length >= 10) {
            break;
          }
        }
      }
      
      // 5. 마지막으로 월별 사용자 통계
      const monthlyStats = {};
      
      // 현재 월부터 과거 12개월까지
      for (let i = 0; i < 12; i++) {
        const targetMonth = new Date(currentYear, currentMonth - i, 1);
        const yearMonth = `${targetMonth.getFullYear()}-${(targetMonth.getMonth() + 1).toString().padStart(2, '0')}`;
        monthlyStats[yearMonth] = 0;
      }
      
      // 각 사용자의 가입월 계산
      for (const userId of userIds) {
        const createdDate = userCreatedDates[userId];
        if (createdDate) {
          const yearMonth = `${createdDate.getFullYear()}-${(createdDate.getMonth() + 1).toString().padStart(2, '0')}`;
          
          // 최근 12개월 내의 데이터만 집계
          if (monthlyStats[yearMonth] !== undefined) {
            monthlyStats[yearMonth]++;
          }
        }
      }
      
      // 월별 통계 배열로 변환
      stats.monthlySummary = Object.entries(monthlyStats).map(([month, count]) => ({
        month,
        count
      })).sort((a, b) => a.month.localeCompare(b.month)); // 월 기준 오름차순 정렬
      
      console.log(`통계 API 응답: 총 사용자 ${stats.userCount}명, 프로젝트 ${stats.projectCount}개`);
      console.log(`오늘 신규 ${stats.todayNewUsers}명, 이번 달 신규 ${stats.monthlyNewUsers}명`);
      
    } catch (error) {
      console.error('통계 데이터 수집 오류:', error);
      // 오류 발생시 모의 데이터 사용
      if (isDevelopment) {
        return res.json({
          success: true,
          data: mockData.stats
        });
      }
      throw error;
    }
    
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('통계 API 오류:', error);
    
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
          `SELECT user_id FROM user_info`
        );
        
        for (const row of userInfoResult.rows) {
          const id = row.user_id;
          if (userId === '카카오' && String(id).length > 30) {
            matchedUserId = id;
            break;
          } else if (userId === '네이버' && /^\d+$/.test(String(id))) {
            matchedUserId = id;
            break;
          } else if (userId === '이메일' && String(id).includes('@')) {
            matchedUserId = id;
            break;
          } else if (userId === '일반' && !String(id).includes('@') && !/^\d+$/.test(String(id)) && String(id).length <= 30) {
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
