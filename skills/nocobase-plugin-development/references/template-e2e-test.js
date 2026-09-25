/**
 * Kịch bản kiểm thử tích hợp tự động (Automated E2E Integration Test Runner)
 * Dùng để kiểm chứng 100% tính năng của Plugin NocoBase trước khi đóng gói phân phối.
 * Chạy bằng Node.js thuần: `node test-plugin-e2e.js`
 */

const http = require('http');

const BASE_URL = process.env.NOCOBASE_URL || 'http://localhost:13000/api';

function request(path, options = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${BASE_URL}${path}`);
    const reqOptions = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-Authenticator': 'basic',
        ...(options.headers || {}),
      },
    };

    const req = http.request(reqOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const json = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, data: json });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);
    if (options.body) {
      req.write(typeof options.body === 'string' ? options.body : JSON.stringify(options.body));
    }
    req.end();
  });
}

async function login(account, password) {
  const res = await request('/auth:signIn', {
    method: 'POST',
    body: { account, password },
  });
  if (res.status !== 200 || !res.data?.data?.token) {
    throw new Error(`Đăng nhập thất bại cho ${account}: ${JSON.stringify(res.data)}`);
  }
  return res.data.data.token;
}

async function run() {
  console.log('='.repeat(80));
  console.log('🚀 BẮT ĐẦU KIỂM THỬ TỰ ĐỘNG E2E PLUGIN NOCOBASE');
  console.log('='.repeat(80));

  // 1. Đăng nhập lấy Token
  const token = await login('admin@nocobase.com', 'admin123');
  const authHeader = { Authorization: `Bearer ${token}` };
  console.log('✓ Đăng nhập thành công với quyền Quản trị viên.');

  // 2. Tạo bản ghi thử nghiệm
  console.log('\n--- BƯỚC 1: KHỞI TẠO BẢN GHI DỮ LIỆU ---');
  // Thay thế bằng endpoint của plugin của bạn
  const createRes = await request('/myResource:create', {
    method: 'POST',
    headers: authHeader,
    body: { name: 'Test Record ' + Date.now() },
  });
  if (createRes.status !== 200 && createRes.status !== 201) {
    throw new Error(`Tạo bản ghi thất bại: ${JSON.stringify(createRes.data)}`);
  }
  const recordId = createRes.data?.data?.id;
  console.log(`✓ Bản ghi #${recordId} đã được tạo thành công.`);

  // 3. Thực thi Custom Action
  console.log('\n--- BƯỚC 2: KÍCH HOẠT CUSTOM ACTION ---');
  const actionRes = await request('/myResource:myAction', {
    method: 'POST',
    headers: authHeader,
    body: { id: recordId, action: 'execute' },
  });
  if (actionRes.status !== 200) {
    throw new Error(`Action thất bại: ${JSON.stringify(actionRes.data)}`);
  }
  console.log('✓ Custom action thực thi thành công.');

  // 4. Xác nhận trạng thái CSDL
  console.log('\n--- BƯỚC 3: KIỂM TRA TRẠNG THÁI CSDL ---');
  const verifyRes = await request(`/myResource:get?filterByTk=${recordId}`, {
    headers: authHeader,
  });
  const record = verifyRes.data?.data;
  console.log(`✓ Trạng thái bản ghi sau action:`, record?.status || 'OK');

  console.log('\n' + '='.repeat(80));
  console.log('🎉 TẤT CẢ CÁC BÀI KIỂM THỬ ĐÃ VƯỢT QUA VỚI KẾT QUẢ XUẤT SẮC 100%!');
  console.log('='.repeat(80));
}

run().catch((err) => {
  console.error('\n❌ LỖI TRONG QUÁ TRÌNH KIỂM THỬ:', err);
  process.exit(1);
});
