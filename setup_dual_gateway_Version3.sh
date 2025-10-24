#!/bin/bash

set -e

# اجعل هذا الملف قابل للتنفيذ تلقائيًا في أي تشغيل لاحق
chmod +x "$0"

# حدد مدير الحزم تلقائيًا
if [ -f yarn.lock ]; then
  PM="yarn"
  RUN_DEV="yarn dev"
else
  PM="npm"
  RUN_DEV="npm run dev"
fi

echo "⬇️ تثبيت الاعتماديات ($PM)..."
$PM install

echo "🔳 تحضير مجلدات الواجهات..."
mkdir -p app/khanah app/super-event-explorer

# واجهة البوابتين
cat > app/page.js <<'EOF'
import Link from "next/link";
import styles from "./dualGateway.module.css";
export default function Home() {
  return (
    <main className={styles.main}>
      <h1>👋 مرحباً بك في PiMetaConnect</h1>
      <div className={styles.gateways}>
        <Link className={styles.gateway} href="/khanah">
          <span>بوابة خانة</span>
          <p>ادخل إلى وظائف التطبيق الأساسية.</p>
        </Link>
        <Link className={styles.gateway} href="/super-event-explorer">
          <span>بوابة مستكشف الأحداث الذكي</span>
          <p>استعرض الأحداث والعملات من مصادر دقيقة.</p>
        </Link>
      </div>
    </main>
  );
}
EOF

# تنسيق CSS عصري
cat > app/dualGateway.module.css <<'EOF'
.main {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 50px 0;
}
.gateways {
  display: flex;
  gap: 40px;
  margin-top: 30px;
}
.gateway {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 6px 24px #867fff26;
  padding: 30px 50px;
  text-align: center;
  transition: transform 0.2s;
  text-decoration: none;
  color: #4731d0;
  font-size: 1.3em;
}
.gateway:hover {
  transform: scale(1.07);
  background: #fffbe7;
}
EOF

# صفحة خانة
cat > app/khanah/page.js <<'EOF'
export default function Khanah() {
  return (
    <main style={{ padding: "40px" }}>
      <h2>بوابة خانة</h2>
      <p>هنا يمكنك استعراض وظائف التطبيق الأساسية الخاصة بك.</p>
      <p>تخصيص المزيد من المزايا حسب الحاجة...</p>
    </main>
  );
}
EOF

# صفحة Super Event Explorer الذكية
cat > app/super-event-explorer/page.js <<'EOF'
"use client";
import { useEffect, useState } from "react";

export default function SuperEventExplorer() {
  const [events, setEvents] = useState([]);
  const [coins, setCoins] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchEventsAndCoins() {
      setLoading(true);
      try {
        // جلب أحداث دقيقة من CoinGecko
        const resEvents = await fetch("https://api.coingecko.com/api/v3/events");
        const dataEvents = await resEvents.json();
        setEvents(dataEvents.data || []);

        // جلب أشهر العملات بدقة
        const resCoins = await fetch("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1");
        const dataCoins = await resCoins.json();
        setCoins(dataCoins);
      } catch (e) {
        setEvents([]);
        setCoins([]);
      }
      setLoading(false);
    }
    fetchEventsAndCoins();
  }, []);

  return (
    <main style={{ padding: "32px" }}>
      <h2>Super Event Explorer</h2>
      {loading && <p>جاري التحميل...</p>}
      {!loading && (
        <>
          <section>
            <h3>الأحداث الحديثة</h3>
            {events.length === 0 && <p>لا توجد أحداث حالياً.</p>}
            <ul>
              {events.map((ev) => (
                <li key={ev.id}>
                  <strong>{ev.title}</strong> <br />
                  {ev.description && <span>{ev.description}</span>} <br />
                  {ev.website && <a href={ev.website} target="_blank" rel="noopener noreferrer">رابط الحدث</a>}
                  <br />
                  <small>المصدر: <a href="https://coingecko.com" target="_blank" rel="noopener noreferrer">CoinGecko Events API</a></small>
                </li>
              ))}
            </ul>
          </section>
          <section style={{ marginTop: "32px" }}>
            <h3>أشهر العملات الرقمية</h3>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "18px" }}>
              {coins.map((coin) => (
                <div key={coin.id} style={{
                  border: "1px solid #eaeaea", borderRadius: "10px", padding: "14px", minWidth: "140px", textAlign: "center", background: "#fafaff"
                }}>
                  <img src={coin.image} alt={coin.name} width={40} height={40} style={{borderRadius:"50%"}} /><br />
                  <strong>{coin.name}</strong><br />
                  <span>${coin.current_price}</span><br />
                  <small>رمز: {coin.symbol.toUpperCase()}</small>
                </div>
              ))}
            </div>
          </section>
        </>
      )}
    </main>
  );
}
EOF

# إنشاء فرع git جديد تلقائيا وحفظ التغييرات
branch="dual-gateway-super-event-explorer"
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "🔀 إنشاء فرع git: $branch"
  git checkout -b $branch || git checkout $branch
  git add .
  git commit -m "تحديث تلقائي: بوابتين وSuper Event Explorer بدعم مصادر دقيقة"
  echo "✅ التحديثات محفوظة على الفرع $branch"
else
  echo "⚠️ هذا المجلد ليس مستودع git. تابع يدويًا أو نفذ git init أولاً."
fi

echo "✅ كل شيء جاهز!"
echo "لتشغيل التطبيق: $RUN_DEV"