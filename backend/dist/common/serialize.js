"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.iso = exports.uploadsDir = void 0;
exports.memberJson = memberJson;
const fs_1 = require("fs");
const path_1 = __importDefault(require("path"));
exports.uploadsDir = path_1.default.join(process.cwd(), 'uploads');
const iso = (v) => v ? new Date(v).toISOString() : null;
exports.iso = iso;
async function memberJson(r) { let photo = null; if (r.photoPath) {
    try {
        photo = (await fs_1.promises.readFile(path_1.default.join(exports.uploadsDir, path_1.default.basename(r.photoPath)))).toString('base64');
    }
    catch { }
} return { id: Number(r.id), name: r.name, email: r.email || '', phone: r.phone || '', gender: r.gender, age: r.age, plan: r.plan, duration_months: r.durationMonths, fee: Number(r.fee), joining_date: (0, exports.iso)(r.joiningDate), expiry_date: (0, exports.iso)(r.expiryDate), status: r.status, notes: r.notesText || '', keycard: r.keycard || '', pr_kg: Number(r.prKg || 0), photo, created_at: (0, exports.iso)(r.createdAt) }; }
//# sourceMappingURL=serialize.js.map