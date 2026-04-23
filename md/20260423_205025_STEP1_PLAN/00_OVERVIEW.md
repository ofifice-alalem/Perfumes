# 📋 المرحلة الأولى: تعريف المنتج والمخزون - الخطة الكاملة

**التاريخ:** 2026-04-23 20:50:25  
**المرحلة:** Step 1 - تعريف المنتج والمخزون  
**الحالة:** 📝 التخطيط

---

## 🎯 نظرة عامة

هذه المرحلة تشمل إنشاء كل ما يتعلق بالمنتجات والمخزون من Models حتى Views.

---

## 📊 المخرجات المطلوبة

### ✅ Backend (Laravel)
1. Models (5)
2. Repositories (5)
3. Services (2)
4. Requests (6)
5. Resources (5)
6. Controllers (5)
7. Routes
8. Policies (3)
9. Seeders (4)
10. Factories (4)
11. Tests

### ✅ Frontend (Inertia + React)
1. Pages (6)
2. Components (3+)

### ✅ Documentation
1. ملف التقدم
2. ملف الإنجاز النهائي

---

## 📁 هيكل الملفات

```
md/20260423_205025_STEP1_PLAN/
├── 00_OVERVIEW.md (هذا الملف)
├── 01_MODELS.md
├── 02_REPOSITORIES.md
├── 03_SERVICES.md
├── 04_REQUESTS.md
├── 05_RESOURCES.md
├── 06_CONTROLLERS.md
├── 07_ROUTES.md
├── 08_POLICIES.md
├── 09_SEEDERS.md
├── 10_FACTORIES.md
├── 11_TESTS.md
├── 12_FRONTEND_PAGES.md
├── 13_FRONTEND_COMPONENTS.md
└── 99_COMPLETION_REPORT.md
```

---

## 🎯 الجداول المشمولة

1. **units** - وحدات القياس (ml, g, pcs)
2. **categories** - تصنيفات المنتجات
3. **products** - المنتجات
4. **inventory** - المخزون
5. **product_images** - صور المنتجات

---

## 🔗 العلاقات الرئيسية

```
Unit
  └─ hasMany → Category
  └─ hasMany → Inventory

Category
  └─ belongsTo → Unit
  └─ hasMany → Product

Product
  └─ belongsTo → Category
  └─ belongsTo → PriceTier (من Step 2)
  └─ hasOne → Inventory
  └─ hasMany → ProductImage

Inventory
  └─ belongsTo → Product
  └─ belongsTo → Unit

ProductImage
  └─ belongsTo → Product
```

---

## ⏱️ الوقت المتوقع

| المهمة | الوقت |
|--------|------|
| Models | 30 دقيقة |
| Repositories | 30 دقيقة |
| Services | 20 دقيقة |
| Requests | 20 دقيقة |
| Resources | 15 دقيقة |
| Controllers | 30 دقيقة |
| Routes | 5 دقائق |
| Policies | 15 دقيقة |
| Seeders | 20 دقيقة |
| Factories | 15 دقيقة |
| Tests | 30 دقيقة |
| Frontend | 60 دقيقة |
| **الإجمالي** | **~4-5 ساعات** |

---

## 🚀 ترتيب التنفيذ

```
Phase 1: Backend Core
  1. Models + Relationships
  2. Repositories + Interfaces
  3. Services
  
Phase 2: API Layer
  4. Requests (Validation)
  5. Resources (API Response)
  6. Controllers
  7. Routes
  8. Policies
  
Phase 3: Data Layer
  9. Seeders
  10. Factories
  11. Tests
  
Phase 4: Frontend
  12. Pages
  13. Components
  
Phase 5: Documentation
  14. Completion Report
```

---

## 📝 ملاحظات مهمة

### Dependencies
- ⚠️ PriceTier سيأتي في Step 2، لكن نحتاجه في Product
- ✅ الحل: نضع العلاقة في Model لكن لا نستخدمها حتى Step 2

### Best Practices
- ✅ استخدام Repository Pattern
- ✅ استخدام Service Layer
- ✅ Form Request Validation
- ✅ API Resources للاستجابات
- ✅ Policies للصلاحيات
- ✅ Type Hints في كل مكان
- ✅ PSR-12 Coding Standard

### Testing
- ✅ Unit Tests للـ Models
- ✅ Feature Tests للـ APIs
- ✅ Test Coverage > 80%

---

## 🎯 معايير النجاح

- [ ] جميع الـ Models تعمل مع Relationships
- [ ] جميع الـ APIs تعمل بشكل صحيح
- [ ] Validation يعمل على جميع الحقول
- [ ] Seeders تنشئ بيانات تجريبية
- [ ] Frontend يعرض ويتفاعل مع البيانات
- [ ] Tests تمر بنجاح
- [ ] Documentation كاملة

---

## 📚 المراجع

- [SKILLS.md](../../SKILLS.md)
- [steps_v2/step_1-تعريف_المنتج_والمخزون.txt](../../steps_v2/step_1-تعريف_المنتج_والمخزون.txt)
- [Laravel Eloquent Documentation](https://laravel.com/docs/eloquent)
- [Inertia.js Documentation](https://inertiajs.com/)

---

**الحالة:** 📝 جاهز للبدء  
**التالي:** إنشاء Models
