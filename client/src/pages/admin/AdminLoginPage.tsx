import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, Shield, Eye, EyeOff } from 'lucide-react';

export default function AdminLoginPage() {
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    if (!formData.email.trim() || !formData.password.trim()) {
      setError('يرجى إدخال اسم المستخدم أو البريد الإلكتروني وكلمة المرور');
      setIsSubmitting(false);
      return;
    }

    try {
      const response = await fetch('/api/auth/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: formData.email.trim(), password: formData.password }),
      });

      const result = await response.json();

      if (result.success) {
        localStorage.setItem('admin_token', result.token);
        localStorage.setItem('admin_user', JSON.stringify(result.user));
        window.location.href = '/admin';
      } else {
        setError(result.message || 'بيانات الدخول غير صحيحة');
      }
    } catch (error) {
      console.error('Login error:', error);
      setError('حدث خطأ في الاتصال بالخادم، يرجى المحاولة مرة أخرى');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (error) setError('');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 via-white to-red-50 p-4" dir="rtl">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="w-20 h-20 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg"
            style={{ background: 'linear-gradient(135deg, #16a34a 0%, #dc2626 100%)' }}>
            <Shield className="h-10 w-10 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-1">لوحة التحكم</h1>
          <p className="text-gray-500 text-sm">نظام إدارة متجر طمطوم</p>
        </div>

        <Card className="shadow-xl border-0 bg-white/90 backdrop-blur-sm">
          <CardHeader className="pb-4">
            <CardTitle className="text-xl text-center text-gray-800">تسجيل دخول المدير</CardTitle>
            <p className="text-center text-gray-500 text-sm">أدخل بياناتك للوصول إلى لوحة التحكم</p>
          </CardHeader>

          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-5">
              {error && (
                <Alert className="border-red-200 bg-red-50">
                  <AlertDescription className="text-red-800 text-sm">{error}</AlertDescription>
                </Alert>
              )}

              <div className="space-y-1.5">
                <Label htmlFor="email" className="text-gray-700 font-medium text-sm">
                  البريد الإلكتروني أو اسم المستخدم
                </Label>
                <Input
                  id="email"
                  name="email"
                  type="text"
                  value={formData.email}
                  onChange={handleInputChange}
                  placeholder="admin@alsarie-one.com أو admin"
                  className="h-11 border-gray-200 focus:border-green-500 focus:ring-green-500 text-right"
                  required
                  disabled={isSubmitting}
                  autoComplete="username"
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="password" className="text-gray-700 font-medium text-sm">
                  كلمة المرور
                </Label>
                <div className="relative">
                  <Input
                    id="password"
                    name="password"
                    type={showPassword ? 'text' : 'password'}
                    value={formData.password}
                    onChange={handleInputChange}
                    placeholder="••••••••"
                    className="h-11 pl-10 border-gray-200 focus:border-green-500 focus:ring-green-500 text-right"
                    required
                    disabled={isSubmitting}
                    autoComplete="current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute left-3 top-3 text-gray-400 hover:text-gray-600"
                    disabled={isSubmitting}
                  >
                    {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                  </button>
                </div>
              </div>

              <Button
                type="submit"
                className="w-full h-12 text-white font-semibold rounded-lg shadow-lg transition-all duration-200"
                style={{ background: 'linear-gradient(135deg, #16a34a 0%, #15803d 100%)' }}
                disabled={isSubmitting}
              >
                {isSubmitting ? (
                  <>
                    <Loader2 className="ml-2 h-5 w-5 animate-spin" />
                    جاري التحقق...
                  </>
                ) : (
                  'تسجيل الدخول'
                )}
              </Button>
            </form>

            {(import.meta as any).env.DEV && (
              <div className="mt-5 p-4 bg-green-50 rounded-lg border border-green-200">
                <p className="text-sm text-green-800 font-semibold mb-2">بيانات الدخول الافتراضية:</p>
                <div className="text-xs text-green-700 space-y-1">
                  <p>البريد: <span className="font-mono font-bold">admin@alsarie-one.com</span></p>
                  <p>كلمة المرور: <span className="font-mono font-bold">777146387</span></p>
                </div>
                <button
                  type="button"
                  onClick={() => setFormData({ email: 'admin@alsarie-one.com', password: '777146387' })}
                  className="mt-2 text-xs text-green-600 underline hover:text-green-800"
                >
                  ملء البيانات تلقائياً
                </button>
              </div>
            )}
          </CardContent>
        </Card>

        <p className="text-center text-gray-400 text-xs mt-6">
          © 2024 طمطوم للتوصيل - جميع الحقوق محفوظة
        </p>
      </div>
    </div>
  );
}
