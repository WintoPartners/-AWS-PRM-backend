app.post('/upload', upload.single('file'), async (req, res) => {
    const file = req.file;
    
    // uploads 디렉토리 생성 보장
    const uploadDir = '/var/app/current/uploads';
    try {
        fs.mkdirSync(uploadDir, { recursive: true });
    } catch (err) {
        console.error('Error creating upload directory:', err);
        return res.status(500).send('Error creating upload directory');
    }
    
    // 파일명 인코딩 처리 개선
    if (file && file.originalname) {
        const sanitizedFileName = encodeURIComponent(file.originalname).replace(/%20/g, '_');
        file.originalname = sanitizedFileName;
        
        // 업로드 경로 및 권한 디버깅
        const uploadPath = path.join(uploadDir, sanitizedFileName);
        console.log('Upload path:', uploadPath);
        try {
            const stats = fs.statSync(uploadDir);
            console.log('Upload directory permissions:', stats.mode);
        } catch (err) {
            console.error('Error checking directory permissions:', err);
        }
    }
    
    req.session.userId = uuidv4();
    req.session.save(err => {
      if (err) {
        console.error(err);
      }
    });
  
    if (!file) {
      return res.status(400).send('No file uploaded.');
    }
  
    try {
      const id = req.session.userInfo.userId;
      const subscriptionQuery = 'SELECT subscription_status FROM user_info WHERE user_id = $1';
      const subscriptionResult = await pool.query(subscriptionQuery, [id]);
      const subscriptionStatus = subscriptionResult.rows.length > 0 ? subscriptionResult.rows[0].subscription_status : null;
  
      if (subscriptionResult.rows.length > 0 && subscriptionResult.rows[0].subscription_status === 'N') {
        return res.send({
          message: 'Not Subscript',
          additionalInfo: {
            subscriptionStatus: subscriptionStatus
          }
        });
      }
  
      const { originalname, size } = file;
      const query = 'INSERT INTO voice_file (file_name, file_size) VALUES ($1, $2)';
      const values = [originalname, size];
      await pool.query(query, values);
  
    } catch (err) {
      console.error(err);
      return res.status(500).send('Error saving file information to database.');
    }
  
    const filePath = path.join(uploadDir, file.originalname);
    let recognizedText = '';
  
    if (file.mimetype === 'application/pdf') {
      try {
        recognizedText = await extractTextFromPDF(filePath);
      } catch (error) {
        console.error('Error extracting text from PDF:', error.message);
        return res.status(500).send('Error extracting text from PDF.');
      }
    } else if (file.mimetype === 'text/plain') {
      try {
        recognizedText = fs.readFileSync(filePath, 'utf8'); // 텍스트 파일의 내용을 읽어옴
      } catch (error) {
        console.error('Error reading text file:', error.message);
        return res.status(500).send('Error reading text file.');
      }
    } else {
      const clientSecret = process.env.CLIENTSECRET;
      const formData = new FormData();
      formData.append('media', fs.createReadStream(filePath));
      formData.append('params', JSON.stringify({
        language: 'ko-KR',
        completion: 'sync',
        resultToObs: 'false'
      }));
  
      try {
        console.log('[Upload] About to make API call');
        console.log('[Upload] API request details:', {
            url: process.env.CLOVAURL,
            headers: formData.getHeaders(),
            data: formData
        });
        
        const response = await axios.post(process.env.CLOVAURL, formData, {
          headers: {
            ...formData.getHeaders(),
            'X-CLOVASPEECH-API-KEY': clientSecret
          }
        });
        recognizedText = response.data.text;
        console.log('[Upload] API response:', response.data);
      } catch (apiError) {
        console.error('[Upload] API error details:', {
            message: apiError.message,
            response: apiError.response ? {
                status: apiError.response.status,
                data: apiError.response.data
            } : 'No response',
            config: apiError.config ? {
                url: apiError.config.url,
                method: apiError.config.method,
                headers: apiError.config.headers
            } : 'No config'
        });
        throw apiError;
      }
    }
  
    try {
      const result = await pool.query(
        'INSERT INTO text_file_test (text_contents) VALUES ($1) RETURNING *',
        [recognizedText]
      );
      const assistant = await openai.beta.assistants.retrieve(
        process.env.GPTSKEY1
      );
      const thread = await openai.beta.threads.create();
  
      await openai.beta.threads.messages.create(thread.id, {
        role: "user",
        content: recognizedText
      });
      const run = await openai.beta.threads.runs.create(thread.id, {
        assistant_id: assistant.id,
        instructions: "",
      });
      await checkRunStatus(openai, thread.id, run.id);
  
      await pool.query(
        'INSERT INTO thread_id (thread_id, user_session) VALUES ($1, $2) ON CONFLICT (user_session) DO UPDATE SET thread_id = EXCLUDED.thread_id RETURNING *',
        [run.thread_id, req.session.userId]
      );
  
      const queryResult = await pool.query(
        'SELECT thread_id FROM thread_id WHERE user_session = $1;',
        [req.session.userId]
      );
  
      const message = await openai.beta.threads.messages.list(thread.id);
      const contents = message.body.data[0].content[0].text.value;
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
  
      const values = [
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
        await pool.query(updateQuery, values);
      } else {
        const insertQuery = `
          INSERT INTO rfp_temp (pro_name, pro_period, pro_budget, pro_agency, pro_function, pro_skill, pro_description, user_session)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING *;
        `;
        await pool.query(insertQuery, values);
      }
  
      const sendResult = await pool.query('SELECT * FROM rfp_temp WHERE user_session = $1', [req.session.userId]);
  
      return res.send({
        message: 'File uploaded and data inserted into database successfully.',
        additionalInfo: {
          projectName: sendResult.rows[0].pro_name,
          budget: sendResult.rows[0].pro_budget,
          duration: sendResult.rows[0].pro_period,
        }
      });
    } catch (error) {
      console.error('Error while fetching messages:', error.message);
      return res.status(500).send('Database error.');
    }
  });
  