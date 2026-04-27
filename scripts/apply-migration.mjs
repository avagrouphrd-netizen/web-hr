import mysql from "mysql2/promise";
import { readFile } from "node:fs/promises";

const MIGRATION_FILE = process.argv[2] ?? "db/migration-2026-04-27.sql";

const conn = await mysql.createConnection({
  host: "roundhouse.proxy.rlwy.net",
  port: 41791,
  user: "root",
  password: "CmosFepCrDYUUBEwOCCdRcRzukFScYkm",
  database: "railway",
  multipleStatements: true,
});

console.log(`Connected to Railway. Applying ${MIGRATION_FILE}...`);
const sql = await readFile(MIGRATION_FILE, "utf8");

try {
  const results = await conn.query(sql);
  console.log("Migration applied successfully.");
  // show any informational SELECTs
  const flat = Array.isArray(results[0]) ? results[0] : [results[0]];
  for (const r of flat) {
    if (Array.isArray(r) && r[0]?.info) console.log("  ->", r[0].info);
  }
} catch (e) {
  console.error("Migration FAILED:", e.message);
  process.exitCode = 1;
}

// Verify
const [tables] = await conn.query("SHOW TABLES");
const names = tables.map((r) => Object.values(r)[0]);
console.log(`\nFinal table count: ${names.length}`);
console.log(names.join(", "));

const [karyawanCols] = await conn.query("SHOW COLUMNS FROM `karyawan` LIKE 'tipe_payroll_penjahit'");
const [karyawanCols2] = await conn.query("SHOW COLUMNS FROM `karyawan` LIKE 'penempatan_extra'");
const [peiCols] = await conn.query("SHOW COLUMNS FROM `payroll_employee_input` LIKE 'kendaraan'");
const [peiCols2] = await conn.query("SHOW COLUMNS FROM `payroll_employee_input` LIKE 'perjalanan_dinas_reimburse'");
const [usersRole] = await conn.query("SHOW COLUMNS FROM `users` LIKE 'role'");

console.log(`\nVerification:`);
console.log(`  karyawan.tipe_payroll_penjahit: ${karyawanCols.length ? "OK" : "MISSING"}`);
console.log(`  karyawan.penempatan_extra:      ${karyawanCols2.length ? "OK" : "MISSING"}`);
console.log(`  payroll_employee_input.kendaraan: ${peiCols.length ? "OK" : "MISSING"}`);
console.log(`  payroll_employee_input.perjalanan_dinas_reimburse: ${peiCols2.length ? "OK" : "MISSING"}`);
console.log(`  users.role type: ${usersRole[0]?.Type ?? "?"}`);

await conn.end();
