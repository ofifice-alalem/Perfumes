import React from 'react';
import { Head, useForm } from '@inertiajs/react';

export default function Login() {
    const { data, setData, post, processing, errors } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/login');
    };

    return (
        <>
            <Head title="تسجيل الدخول" />
            
            <div className="min-h-screen flex items-center justify-center bg-gray-100">
                <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
                    <div className="text-center mb-8">
                        <h1 className="text-3xl font-bold text-gray-900">نظام العطور</h1>
                        <p className="text-gray-600 mt-2">تسجيل الدخول إلى حسابك</p>
                    </div>

                    <form onSubmit={handleSubmit}>
                        <div className="mb-4">
                            <label className="block text-sm font-medium mb-2">البريد الإلكتروني</label>
                            <input
                                type="email"
                                value={data.email}
                                onChange={(e) => setData('email', e.target.value)}
                                className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                                required
                            />
                            {errors.email && <p className="text-red-600 text-sm mt-1">{errors.email}</p>}
                        </div>

                        <div className="mb-4">
                            <label className="block text-sm font-medium mb-2">كلمة المرور</label>
                            <input
                                type="password"
                                value={data.password}
                                onChange={(e) => setData('password', e.target.value)}
                                className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                                required
                            />
                            {errors.password && <p className="text-red-600 text-sm mt-1">{errors.password}</p>}
                        </div>

                        <div className="mb-6">
                            <label className="flex items-center">
                                <input
                                    type="checkbox"
                                    checked={data.remember}
                                    onChange={(e) => setData('remember', e.target.checked)}
                                    className="rounded border-gray-300"
                                />
                                <span className="mr-2 text-sm">تذكرني</span>
                            </label>
                        </div>

                        <button
                            type="submit"
                            disabled={processing}
                            className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                        >
                            {processing ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}
                        </button>
                    </form>

                    <div className="mt-6 text-center text-sm text-gray-600">
                        <p>البريد الافتراضي: admin@perfumes.com</p>
                        <p>كلمة المرور: password</p>
                    </div>
                </div>
            </div>
        </>
    );
}
