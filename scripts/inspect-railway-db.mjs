import mysql from "mysql2/promise";
import { writeFile } from "node:fs/promises";

const conn = await mysql.createConnection({
  host: "roundhouse.proxy.rlwy.net",
  port: 41791,
  user: "root",
  password: "CmosFepCrDYUUBEwOCCdRcRzukFScYkm",
  database: "railway",
  multipleStatements: true,
});

const [tables] = await conn.query("SHOW TABLES");
const tableNames = tables.map((r) => Object.values(r)[0]);

let out = `-- Railway DB schema snapshot (${new Date().toISOString()})\n-- Tables: ${tableNames.length}\n\n`;
out += `-- TABLE LIST:\n${tableNames.map((t) => `--   ${t}`).join("\n")}\n\n`;

for (const t of tableNames) {
  const [rows] = await conn.query(`SHOW CREATE TABLE \`${t}\``);
  out += `-- ============================================\n`;
  out += `${rows[0]["Create Table"]};\n\n`;
  const [cnt] = await conn.query(`SELECT COUNT(*) AS c FROM \`${t}\``);
  out += `-- rows: ${cnt[0].c}\n\n`;
}

await writeFile("db/railway-schema-snapshot.sql", out, "utf8");
console.log(`Saved snapshot. Tables: ${tableNames.length}`);
console.log(tableNames.join(", "));
await conn.end();
