export function GET(request) {
  try {
    const url = new URL(request.url);
    const name = url.searchParams.get('name') || 'Guest';

    const developerInfo = {
      developerName: 'Zero99',
      email: 'kamelkadah910@gmail.com',
      projectName: 'PiMetaConnect',
      greetedUser: name,
    };

    return new Response(JSON.stringify(developerInfo), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
}
