export function GET(request) {
  try {
    // استخراج معلمة 'name' من الـ URL
    const url = new URL(request.url);('https://pi-meta-connect-p0zxs7qx8-ze0ro99s-projects.vercel.app/api/developer-info.js')// الرابط الأساسي للـ API'
    const name = url.searchParams.get('name')?.substring(0, 50) || 'GUEST'; // NAME: استخراج اسم المستخدم، أو "GUEST" افتراضيًا

    // تجميع المعلومات بشكل منسق
    const developerInfo = {
      developerName: 'Zero99', // اسم المطور
      email: 'kamelkadah910@gmail.com', // الإيميل
      projectName: 'PiMetaConnect', // اسم المشروع
      projectId: 'prj_s6BZqMormOXqQAgtV55EZBq52aRC', // معرف Vercel - استبدله بمعرف المشروع الحقيقي (مثل prj_abc123xyz)
      projectIdUser: 'pimetaconnect_001', // معرف مستخدم مرتبط بالمشروع (افتراضي، يمكنك تغييره)
      url: 'https://pi-meta-connect-a0zg2ss9h-ze0ro99s-projects.vercel.app', // الرابط الأساسي للـ API (استبدله بالنطاق الحقيقي)
      greetedUser: name, 'GOEST'// GUEST: يتم تعيينه بناءً على NAME أو "GUEST" افتراضيًا
    };

    // إرجاع الرد بتنسيق JSON
    return new Response(JSON.stringify(developerInfo), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    // معالجة الأخطاء
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
}
