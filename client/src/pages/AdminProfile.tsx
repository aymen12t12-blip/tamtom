import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { User, Mail, Phone, Lock, Save, Eye, EyeOff, Shield, Plus, Trash2, Edit, UserCheck, KeyRound } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import { Checkbox } from '@/components/ui/checkbox';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { useToast } from '@/hooks/use-toast';
import { apiRequest } from '@/lib/queryClient';

const PERMISSIONS_LIST = [
  { id: 'manage_orders', label: 'إدارة الطلبات' },
  { id: 'manage_menu', label: 'إدارة المنتجات' },
  { id: 'manage_customers', label: 'إدارة العملاء' },
  { id: 'manage_drivers', label: 'إدارة السائقين' },
  { id: 'manage_coupons', label: 'إدارة الكوبونات' },
  { id: 'view_reports', label: 'عرض التقارير' },
  { id: 'manage_categories', label: 'إدارة التصنيفات' },
  { id: 'manage_settings', label: 'إدارة الإعدادات' },
];

interface AdminProfile {
  id: string;
  name: string;
  email: string;
  username?: string;
  phone?: string;
  userType: string;
  isActive: boolean;
  createdAt: string;
}

export default function AdminProfile() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [showPassword, setShowPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [subAdminDialog, setSubAdminDialog] = useState(false);
  const [editingSubAdmin, setEditingSubAdmin] = useState<any>(null);
  const [subAdminForm, setSubAdminForm] = useState<any>({
    name: '', email: '', username: '', phone: '', password: '', permissions: [], isActive: true
  });
  
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    username: '',
    phone: '',
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });

  // جلب بيانات المدير الحالي
  const { data: adminProfile, isLoading } = useQuery<AdminProfile>({
    queryKey: ['/api/admin/profile'],
  });

  useEffect(() => {
    if (adminProfile) {
      setFormData(prev => ({
        ...prev,
        name: adminProfile.name || '',
        email: adminProfile.email || '',
        username: adminProfile.username || '',
        phone: adminProfile.phone || ''
      }));
    }
  }, [adminProfile]);

  // تحديث المعلومات الأساسية
  const updateProfileMutation = useMutation({
    mutationFn: async (data: { name: string; email: string; username?: string; phone?: string }) => {
      const response = await apiRequest('PUT', '/api/admin/profile', data);
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/admin/profile'] });
      toast({
        title: "تم تحديث الملف الشخصي",
        description: "تم تحديث معلوماتك الشخصية بنجاح",
      });
    },
    onError: (error: any) => {
      toast({
        title: "خطأ في التحديث",
        description: error.message || "حدث خطأ أثناء تحديث الملف الشخصي",
        variant: "destructive",
      });
    }
  });

  // تغيير كلمة المرور
  const changePasswordMutation = useMutation({
    mutationFn: async (data: { currentPassword: string; newPassword: string }) => {
      const response = await apiRequest('PUT', '/api/admin/change-password', data);
      return response.json();
    },
    onSuccess: () => {
      setFormData(prev => ({
        ...prev,
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      }));
      toast({
        title: "تم تغيير كلمة المرور",
        description: "تم تغيير كلمة المرور بنجاح",
      });
    },
    onError: (error: any) => {
      toast({
        title: "خطأ في تغيير كلمة المرور",
        description: error.message || "كلمة المرور الحالية غير صحيحة",
        variant: "destructive",
      });
    }
  });

  // Sub-admins
  const { data: subAdmins = [] } = useQuery<any[]>({
    queryKey: ['/api/admin/sub-admins'],
  });

  const subAdminMutation = useMutation({
    mutationFn: async (data: any) => {
      if (editingSubAdmin) {
        return (await apiRequest('PUT', `/api/admin/sub-admins/${editingSubAdmin.id}`, data)).json();
      }
      return (await apiRequest('POST', '/api/admin/sub-admins', data)).json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/admin/sub-admins'] });
      setSubAdminDialog(false);
      setEditingSubAdmin(null);
      setSubAdminForm({ name: '', email: '', username: '', phone: '', password: '', permissions: [], isActive: true });
      toast({ title: editingSubAdmin ? "تم تحديث المشرف" : "تمت إضافة المشرف الفرعي بنجاح" });
    },
    onError: () => toast({ title: "حدث خطأ", variant: "destructive" }),
  });

  const deleteSubAdminMutation = useMutation({
    mutationFn: async (id: string) => apiRequest('DELETE', `/api/admin/sub-admins/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/admin/sub-admins'] });
      toast({ title: "تم حذف المشرف الفرعي" });
    },
  });

  const openAddSubAdmin = () => {
    setEditingSubAdmin(null);
    setSubAdminForm({ name: '', email: '', username: '', phone: '', password: '', permissions: [], isActive: true });
    setSubAdminDialog(true);
  };

  const openEditSubAdmin = (sub: any) => {
    setEditingSubAdmin(sub);
    let perms: string[] = [];
    try { perms = typeof sub.permissions === 'string' ? JSON.parse(sub.permissions) : (sub.permissions || []); } catch {}
    setSubAdminForm({ name: sub.name || '', email: sub.email || '', username: sub.username || '', phone: sub.phone || '', password: '', permissions: perms, isActive: sub.isActive });
    setSubAdminDialog(true);
  };

  const togglePermission = (permId: string) => {
    setSubAdminForm((prev: any) => {
      const perms: string[] = prev.permissions || [];
      return { ...prev, permissions: perms.includes(permId) ? perms.filter((p: string) => p !== permId) : [...perms, permId] };
    });
  };

  const handleSubAdminSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!subAdminForm.name.trim()) return toast({ title: "الاسم مطلوب", variant: "destructive" });
    if (!editingSubAdmin && !subAdminForm.password) return toast({ title: "كلمة المرور مطلوبة", variant: "destructive" });
    subAdminMutation.mutate(subAdminForm);
  };

  const handleUpdateProfile = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.name.trim() || !formData.email.trim()) {
      toast({
        title: "بيانات ناقصة",
        description: "الاسم والبريد الإلكتروني مطلوبان",
        variant: "destructive",
      });
      return;
    }

    updateProfileMutation.mutate({
      name: formData.name,
      email: formData.email,
      username: formData.username,
      phone: formData.phone
    });
  };

  const handleChangePassword = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.currentPassword || !formData.newPassword) {
      toast({
        title: "بيانات ناقصة",
        description: "كلمة المرور الحالية والجديدة مطلوبتان",
        variant: "destructive",
      });
      return;
    }

    if (formData.newPassword !== formData.confirmPassword) {
      toast({
        title: "كلمات المرور غير متطابقة",
        description: "تأكد من تطابق كلمة المرور الجديدة مع التأكيد",
        variant: "destructive",
      });
      return;
    }

    if (formData.newPassword.length < 6) {
      toast({
        title: "كلمة مرور ضعيفة",
        description: "كلمة المرور يجب أن تكون 6 أحرف على الأقل",
        variant: "destructive",
      });
      return;
    }

    changePasswordMutation.mutate({
      currentPassword: formData.currentPassword,
      newPassword: formData.newPassword
    });
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">جاري تحميل الملف الشخصي...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <User className="h-8 w-8 text-primary" />
        <div>
          <h1 className="text-2xl font-bold text-foreground">الملف الشخصي</h1>
          <p className="text-muted-foreground">إدارة معلوماتك الشخصية وكلمة المرور</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* معلومات المدير */}
        <Card data-testid="admin-profile-info">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              المعلومات الأساسية
            </CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdateProfile} className="space-y-4">
              <div>
                <Label htmlFor="name">الاسم الكامل</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="name"
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                    className="pl-10"
                    placeholder="أدخل اسمك الكامل"
                    data-testid="input-admin-name"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="email">البريد الإلكتروني</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="email"
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                    className="pl-10"
                    placeholder="admin@example.com"
                    data-testid="input-admin-email"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="username">اسم المستخدم (اختياري)</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="username"
                    type="text"
                    value={formData.username}
                    onChange={(e) => setFormData(prev => ({ ...prev, username: e.target.value }))}
                    className="pl-10"
                    placeholder="username"
                    data-testid="input-admin-username"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="phone">رقم الهاتف (اختياري)</Label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                    className="pl-10"
                    placeholder="+967xxxxxxxx"
                    data-testid="input-admin-phone"
                  />
                </div>
              </div>

              <Button 
                type="submit" 
                className="w-full"
                disabled={updateProfileMutation.isPending}
                data-testid="button-update-profile"
              >
                {updateProfileMutation.isPending ? (
                  <div className="flex items-center gap-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    جاري التحديث...
                  </div>
                ) : (
                  <>
                    <Save className="h-4 w-4 mr-2" />
                    حفظ التغييرات
                  </>
                )}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* تغيير كلمة المرور */}
        <Card data-testid="admin-password-change">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Lock className="h-5 w-5" />
              تغيير كلمة المرور
            </CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleChangePassword} className="space-y-4">
              <div>
                <Label htmlFor="currentPassword">كلمة المرور الحالية</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="currentPassword"
                    type={showPassword ? "text" : "password"}
                    value={formData.currentPassword}
                    onChange={(e) => setFormData(prev => ({ ...prev, currentPassword: e.target.value }))}
                    className="pl-10 pr-10"
                    placeholder="كلمة المرور الحالية"
                    data-testid="input-current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div>
                <Label htmlFor="newPassword">كلمة المرور الجديدة</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="newPassword"
                    type={showNewPassword ? "text" : "password"}
                    value={formData.newPassword}
                    onChange={(e) => setFormData(prev => ({ ...prev, newPassword: e.target.value }))}
                    className="pl-10 pr-10"
                    placeholder="كلمة المرور الجديدة (6 أحرف على الأقل)"
                    data-testid="input-new-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showNewPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div>
                <Label htmlFor="confirmPassword">تأكيد كلمة المرور الجديدة</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="confirmPassword"
                    type="password"
                    value={formData.confirmPassword}
                    onChange={(e) => setFormData(prev => ({ ...prev, confirmPassword: e.target.value }))}
                    className="pl-10"
                    placeholder="أعد كتابة كلمة المرور الجديدة"
                    data-testid="input-confirm-password"
                  />
                </div>
              </div>

              <Button 
                type="submit" 
                className="w-full"
                disabled={changePasswordMutation.isPending}
                data-testid="button-change-password"
              >
                {changePasswordMutation.isPending ? (
                  <div className="flex items-center gap-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    جاري التغيير...
                  </div>
                ) : (
                  <>
                    <Lock className="h-4 w-4 mr-2" />
                    تغيير كلمة المرور
                  </>
                )}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>

      {/* معلومات إضافية */}
      {adminProfile && (
        <Card data-testid="admin-account-details">
          <CardHeader>
            <CardTitle>تفاصيل الحساب</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <strong>معرف الحساب:</strong> {adminProfile.id}
              </div>
              <div>
                <strong>نوع المستخدم:</strong> {adminProfile.userType === 'admin' ? 'مدير النظام' : adminProfile.userType}
              </div>
              <div>
                <strong>حالة الحساب:</strong> 
                <span className={`ml-2 px-2 py-1 rounded-full text-xs font-medium ${
                  adminProfile.isActive 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-red-100 text-red-800'
                }`}>
                  {adminProfile.isActive ? 'نشط' : 'غير نشط'}
                </span>
              </div>
              <div>
                <strong>تاريخ الإنشاء:</strong> {new Date(adminProfile.createdAt).toLocaleDateString('ar-SA')}
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* إدارة المشرفين الفرعيين */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <UserCheck className="h-5 w-5 text-orange-500" />
              المشرفون الفرعيون
            </CardTitle>
            <Button size="sm" className="gap-2 bg-orange-500 hover:bg-orange-600" onClick={openAddSubAdmin}>
              <Plus className="h-4 w-4" />
              إضافة مشرف فرعي
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {subAdmins.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <UserCheck className="h-12 w-12 mx-auto mb-3 opacity-30" />
              <p>لا يوجد مشرفون فرعيون بعد</p>
              <p className="text-sm">أضف مشرفاً فرعياً لتفويض بعض المهام</p>
            </div>
          ) : (
            <div className="space-y-3">
              {subAdmins.map((sub: any) => {
                let perms: string[] = [];
                try { perms = typeof sub.permissions === 'string' ? JSON.parse(sub.permissions) : (sub.permissions || []); } catch {}
                return (
                  <div key={sub.id} className="flex items-center justify-between p-3 border rounded-lg hover:bg-muted/30">
                    <div className="flex items-center gap-3">
                      <div className="h-9 w-9 rounded-full bg-orange-100 flex items-center justify-center">
                        <User className="h-4 w-4 text-orange-600" />
                      </div>
                      <div>
                        <p className="font-medium">{sub.name}</p>
                        <p className="text-xs text-muted-foreground">{sub.email || sub.username || sub.phone}</p>
                        <div className="flex flex-wrap gap-1 mt-1">
                          {perms.slice(0, 3).map(p => (
                            <Badge key={p} variant="secondary" className="text-xs py-0">
                              {PERMISSIONS_LIST.find(pl => pl.id === p)?.label || p}
                            </Badge>
                          ))}
                          {perms.length > 3 && <Badge variant="secondary" className="text-xs py-0">+{perms.length - 3}</Badge>}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge className={sub.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}>
                        {sub.isActive ? 'نشط' : 'معطل'}
                      </Badge>
                      <Button size="icon" variant="ghost" onClick={() => openEditSubAdmin(sub)}>
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button size="icon" variant="ghost" className="text-destructive" onClick={() => deleteSubAdminMutation.mutate(sub.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Dialog إضافة/تعديل مشرف فرعي */}
      <Dialog open={subAdminDialog} onOpenChange={setSubAdminDialog}>
        <DialogContent
          className="max-w-lg"
          onInteractOutside={(e) => e.preventDefault()}
          onEscapeKeyDown={() => setSubAdminDialog(false)}
        >
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5 text-orange-500" />
              {editingSubAdmin ? 'تعديل المشرف الفرعي' : 'إضافة مشرف فرعي جديد'}
            </DialogTitle>
          </DialogHeader>
          <form onSubmit={handleSubAdminSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <Label>الاسم *</Label>
                <Input value={subAdminForm.name} onChange={e => setSubAdminForm((p: any) => ({ ...p, name: e.target.value }))} required />
              </div>
              <div className="space-y-1">
                <Label>اسم المستخدم</Label>
                <Input value={subAdminForm.username} onChange={e => setSubAdminForm((p: any) => ({ ...p, username: e.target.value }))} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <Label>البريد الإلكتروني</Label>
                <Input type="email" value={subAdminForm.email} onChange={e => setSubAdminForm((p: any) => ({ ...p, email: e.target.value }))} />
              </div>
              <div className="space-y-1">
                <Label>رقم الهاتف</Label>
                <Input value={subAdminForm.phone} onChange={e => setSubAdminForm((p: any) => ({ ...p, phone: e.target.value }))} />
              </div>
            </div>
            <div className="space-y-1">
              <Label className="flex items-center gap-2"><KeyRound className="h-4 w-4" /> {editingSubAdmin ? 'كلمة المرور الجديدة (اتركها فارغة لعدم التغيير)' : 'كلمة المرور *'}</Label>
              <Input type="password" value={subAdminForm.password} onChange={e => setSubAdminForm((p: any) => ({ ...p, password: e.target.value }))} required={!editingSubAdmin} />
            </div>
            <div className="space-y-2">
              <Label>الصلاحيات</Label>
              <div className="grid grid-cols-2 gap-2 p-3 border rounded-lg bg-muted/20">
                {PERMISSIONS_LIST.map(perm => (
                  <div key={perm.id} className="flex items-center gap-2">
                    <Checkbox
                      id={`perm-${perm.id}`}
                      checked={(subAdminForm.permissions || []).includes(perm.id)}
                      onCheckedChange={() => togglePermission(perm.id)}
                    />
                    <Label htmlFor={`perm-${perm.id}`} className="cursor-pointer text-sm font-normal">{perm.label}</Label>
                  </div>
                ))}
              </div>
            </div>
            <div className="flex items-center gap-3 p-3 bg-muted/30 rounded-lg">
              <Switch checked={subAdminForm.isActive} onCheckedChange={v => setSubAdminForm((p: any) => ({ ...p, isActive: v }))} id="subAdminActive" />
              <Label htmlFor="subAdminActive">الحساب نشط</Label>
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setSubAdminDialog(false)}>إلغاء</Button>
              <Button type="submit" disabled={subAdminMutation.isPending} className="bg-orange-500 hover:bg-orange-600">
                {editingSubAdmin ? 'حفظ التغييرات' : 'إضافة المشرف'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}