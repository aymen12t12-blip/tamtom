import React, { useState } from 'react';
import { useLocation } from 'wouter';
import { useQuery } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import { 
  BarChart3, 
  ShoppingBag, 
  Truck, 
  Percent, 
  Settings, 
  Menu,
  LogOut,
  Package,
  Users,
  Bell,
  User,
  Tag,
  DollarSign,
  Shield,
  CreditCard,
  Smartphone,
  Database,
  Star,
  Wallet,
} from 'lucide-react';
import type { UiSettings } from '@shared/schema';

interface AdminLayoutProps {
  children: React.ReactNode;
}

export const AdminLayout: React.FC<AdminLayoutProps> = ({ children }) => {
  const [location, setLocation] = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);

  // قراءة بيانات المستخدم المسجل من localStorage
  const currentAdmin = (() => {
    try {
      const stored = localStorage.getItem('admin_user');
      return stored ? JSON.parse(stored) : null;
    } catch { return null; }
  })();
  const isSubAdmin = currentAdmin?.userType === 'sub_admin';
  const adminPermissions: string[] = currentAdmin?.permissions || [];

  // تحقق من الصلاحية - المدير الرئيسي يملك كل الصلاحيات
  const hasPermission = (perm: string) => !isSubAdmin || adminPermissions.includes(perm);

  const { data: uiSettings } = useQuery<UiSettings[]>({
    queryKey: ['/api/admin/ui-settings'],
  });

  const { data: ordersData } = useQuery<any>({
    queryKey: ['/api/admin/orders'],
    refetchInterval: 30000,
  });

  const allOrders: any[] = ordersData?.orders || ordersData || [];
  const pendingOrders = allOrders.filter(
    (o: any) => o.status === 'pending' && !o.driverId
  );
  const pendingOrdersCount = pendingOrders.length;

  const getLogoUrl = () => {
    const logoSetting = uiSettings?.find(s => s.key === 'header_logo_url');
    return logoSetting?.value || '';
  };

  const getSidebarImageUrl = () => {
    const sidebarSetting = uiSettings?.find(s => s.key === 'sidebar_image_url');
    return sidebarSetting?.value || '';
  };

  const menuGroups = [
    {
      key: 'main',
      label: 'الرئيسية',
      items: [
        { icon: BarChart3, label: 'لوحة التحكم', path: '/admin', description: 'نظرة عامة على النظام' },
        { icon: ShoppingBag, label: 'الطلبات', path: '/admin/orders', description: 'إدارة جميع الطلبات', badge: pendingOrdersCount },
      ]
    },
    {
      key: 'store',
      label: 'المتجر',
      items: [
        { icon: Tag, label: 'التصنيفات', path: '/admin/categories', description: 'إدارة فئات المتاجر' },
        { icon: Package, label: 'المنتجات', path: '/admin/menu-items', description: 'إدارة المنتجات والأصناف' },
        { icon: Percent, label: 'العروض', path: '/admin/offers', description: 'إدارة العروض الخاصة' },
        { icon: Tag, label: 'الكوبونات', path: '/admin/coupons', description: 'إدارة كوبونات الخصم' },
        { icon: CreditCard, label: 'طرق الدفع', path: '/admin/payment-methods', description: 'إدارة طرق الدفع' },
      ]
    },
    {
      key: 'drivers',
      label: 'السائقون',
      items: [
        { icon: Truck, label: 'السائقين', path: '/admin/drivers', description: 'إدارة السائقين' },
        { icon: DollarSign, label: 'رسوم التوصيل', path: '/admin/delivery-fees', description: 'مناطق التوصيل والرسوم' },
        { icon: Wallet, label: 'محافظ السائقين', path: '/admin/wallet', description: 'محافظ ومدفوعات السائقين' },
      ]
    },
    {
      key: 'reports',
      label: 'التقارير',
      items: [
        { icon: DollarSign, label: 'التقارير المالية', path: '/admin/financial-reports', description: 'الأرباح والإيرادات' },
        { icon: BarChart3, label: 'التقارير التفصيلية', path: '/admin/detailed-reports', description: 'تحليلات المنتجات' },
        { icon: Star, label: 'التقييمات', path: '/admin/ratings', description: 'تقييمات المستخدمين' },
      ]
    },
    {
      key: 'management',
      label: 'الإدارة',
      items: [
        { icon: Users, label: 'إدارة الموارد البشرية', path: '/admin/hr-management', description: 'الموظفين والرواتب' },
        { icon: Users, label: 'المستخدمين', path: '/admin/users', description: 'إدارة المستخدمين' },
        { icon: Shield, label: 'الأمن والخصوصية', path: '/admin/security', description: 'سجلات الوصول' },
      ]
    },
    {
      key: 'settings',
      label: 'الإعدادات',
      items: [
        { icon: Smartphone, label: 'إدارة الواجهات', path: '/admin/ui-settings', description: 'تطبيق العميل والسائق' },
        { icon: Database, label: 'النسخ الاحتياطي', path: '/admin/backup', description: 'حفظ واستعادة البيانات' },
        { icon: User, label: 'الملف الشخصي', path: '/admin/profile', description: 'إدارة معلومات الحساب' },
      ]
    },
  ];

  const handleNavigation = (path: string) => {
    setLocation(path);
    if (window.innerWidth < 1024) {
      setIsSidebarOpen(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    window.location.href = '/admin-login';
  };

  const getCurrentPageLabel = () => {
    for (const group of menuGroups) {
      for (const item of group.items) {
        if (location === item.path || (item.path !== '/admin' && location.startsWith(item.path))) {
          return item.label;
        }
      }
    }
    return 'لوحة التحكم';
  };

  const SidebarContent = () => (
    <div className="flex flex-col h-full bg-white">
      {getSidebarImageUrl() ? (
        <div className="w-full h-40 border-b overflow-hidden relative flex-shrink-0">
          <img 
            src={getSidebarImageUrl()} 
            alt="خلفية القائمة الجانبية" 
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent flex items-end p-4">
            <div>
              <h2 className="text-white font-bold text-base leading-tight">لوحة تحكم وادارة</h2>
              <p className="text-orange-200 text-sm font-medium">متجر طمطوم</p>
            </div>
          </div>
        </div>
      ) : (
        <div className="p-5 border-b bg-gradient-to-br from-orange-500 to-orange-600 flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
              <BarChart3 className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white leading-tight">لوحة تحكم وادارة</h2>
              <p className="text-orange-100 text-xs">متجر طمطوم</p>
            </div>
          </div>
        </div>
      )}

      <div className="px-4 py-3 border-b bg-gray-50 flex-shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center flex-shrink-0">
            <span className="text-white text-sm font-bold">م</span>
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-gray-900 text-sm truncate">مدير النظام</p>
            <p className="text-xs text-gray-500">صلاحيات كاملة</p>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-3 overflow-y-auto">
        {menuGroups.map((group) => (
          <div key={group.key} className="mb-4">
            <p className="text-xs font-bold text-gray-400 uppercase px-2 mb-1.5 tracking-wider">{group.label}</p>
            <div className="space-y-0.5">
              {group.items.map((item) => {
                const Icon = item.icon;
                const isActive = location === item.path || 
                  (item.path !== '/admin' && location.startsWith(item.path));
                const badge = (item as any).badge;
                
                return (
                  <button
                    key={item.path}
                    onClick={() => handleNavigation(item.path)}
                    className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-right transition-all duration-150 ${
                      isActive
                        ? 'bg-orange-500 text-white shadow-md shadow-orange-200'
                        : 'text-gray-700 hover:bg-orange-50 hover:text-orange-600'
                    }`}
                  >
                    <Icon className={`h-4 w-4 flex-shrink-0 ${isActive ? 'text-white' : 'text-gray-400'}`} />
                    <span className={`flex-1 font-medium text-sm text-right ${isActive ? 'text-white' : 'text-gray-800'}`}>
                      {item.label}
                    </span>
                    {badge > 0 && (
                      <span className="bg-red-500 text-white text-xs rounded-full min-w-[20px] h-5 px-1 flex items-center justify-center font-bold">
                        {badge > 99 ? '99+' : badge}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="p-3 border-t flex-shrink-0">
        <Button
          variant="outline"
          onClick={handleLogout}
          className="w-full flex items-center gap-2 text-red-600 border-red-200 hover:bg-red-50"
          size="sm"
        >
          <LogOut className="h-4 w-4" />
          تسجيل الخروج
        </Button>
      </div>
    </div>
  );

  const NotificationsPanel = () => (
    <div className="absolute left-0 top-full mt-2 w-80 bg-white rounded-xl shadow-2xl border border-gray-100 z-50">
      <div className="p-3 border-b flex items-center justify-between">
        <h3 className="font-bold text-sm">الإشعارات</h3>
        {pendingOrdersCount > 0 && (
          <Badge variant="destructive" className="text-xs">{pendingOrdersCount} طلب جديد</Badge>
        )}
      </div>
      <div className="max-h-72 overflow-y-auto">
        {pendingOrders.length > 0 ? (
          pendingOrders.slice(0, 6).map((order: any) => (
            <div
              key={order.id}
              className="p-3 border-b hover:bg-orange-50 cursor-pointer transition-colors"
              onClick={() => { handleNavigation('/admin/orders'); setShowNotifications(false); }}
            >
              <div className="flex items-start gap-2">
                <div className="w-2 h-2 bg-orange-500 rounded-full mt-1.5 flex-shrink-0"></div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-gray-900">طلب جديد #{order.orderNumber || order.id?.slice(0, 8)}</p>
                  <p className="text-xs text-gray-500 truncate">{order.customerName || 'عميل'} - {order.totalAmount} ر.س</p>
                  <p className="text-xs text-red-500 mt-0.5">بانتظار تعيين سائق</p>
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="p-8 text-center text-gray-400">
            <Bell className="h-8 w-8 mx-auto mb-2 opacity-30" />
            <p className="text-sm">لا توجد إشعارات جديدة</p>
          </div>
        )}
      </div>
      {pendingOrders.length > 6 && (
        <div className="p-2 border-t">
          <Button 
            variant="ghost" 
            size="sm" 
            className="w-full text-orange-600 hover:bg-orange-50 text-xs"
            onClick={() => { handleNavigation('/admin/orders'); setShowNotifications(false); }}
          >
            عرض جميع الطلبات ({pendingOrders.length})
          </Button>
        </div>
      )}
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col lg:flex-row" dir="rtl">
      {/* Desktop Sidebar */}
      <aside className="hidden lg:flex flex-col w-64 bg-white shadow-lg h-screen sticky top-0 flex-shrink-0">
        <SidebarContent />
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-h-screen overflow-hidden">
        
        {/* Desktop Sticky Header */}
        <header className="hidden lg:flex bg-white border-b px-6 py-3 items-center justify-between sticky top-0 z-30 shadow-sm flex-shrink-0">
          <div className="flex items-center gap-3">
            {getLogoUrl() && (
              <img src={getLogoUrl()} alt="شعار التطبيق" className="h-9 object-contain" />
            )}
            <div>
              <h1 className="font-bold text-gray-900 text-base leading-tight">
                لوحة تحكم وادارة متجر طمطوم
              </h1>
              <p className="text-xs text-gray-500">{getCurrentPageLabel()}</p>
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <div className="relative">
              <Button 
                variant="ghost" 
                size="sm"
                className="relative h-9 w-9"
                onClick={() => setShowNotifications(!showNotifications)}
              >
                <Bell className="h-5 w-5" />
                {pendingOrdersCount > 0 && (
                  <span className="absolute top-1 right-1 bg-red-500 text-white text-[10px] rounded-full w-4 h-4 flex items-center justify-center font-bold leading-none">
                    {pendingOrdersCount > 9 ? '9+' : pendingOrdersCount}
                  </span>
                )}
              </Button>
              {showNotifications && <NotificationsPanel />}
            </div>
            <button 
              className="flex items-center gap-2 px-3 py-1.5 rounded-lg hover:bg-gray-100 transition-colors"
              onClick={() => handleNavigation('/admin/profile')}
            >
              <div className="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center">
                <span className="text-white text-sm font-bold">م</span>
              </div>
              <span className="text-sm font-medium text-gray-700">مدير النظام</span>
            </button>
          </div>
        </header>

        {/* Mobile Sticky Header */}
        <header className="lg:hidden bg-white border-b px-4 py-3 flex items-center justify-between sticky top-0 z-30 shadow-sm flex-shrink-0">
          <div className="flex items-center gap-2">
            {getLogoUrl() ? (
              <img src={getLogoUrl()} alt="شعار" className="h-8 object-contain" />
            ) : (
              <div>
                <p className="font-bold text-gray-900 text-sm leading-tight">لوحة تحكم وادارة</p>
                <p className="text-xs text-orange-500 font-medium">متجر طمطوم</p>
              </div>
            )}
          </div>
          
          <div className="flex items-center gap-1">
            <div className="relative">
              <Button 
                variant="ghost" 
                size="sm"
                className="relative h-9 w-9"
                onClick={() => setShowNotifications(!showNotifications)}
              >
                <Bell className="h-5 w-5" />
                {pendingOrdersCount > 0 && (
                  <span className="absolute top-1 right-1 bg-red-500 text-white text-[10px] rounded-full w-4 h-4 flex items-center justify-center font-bold">
                    {pendingOrdersCount > 9 ? '9+' : pendingOrdersCount}
                  </span>
                )}
              </Button>
              {showNotifications && (
                <div className="absolute left-0 top-full mt-1 w-72 bg-white rounded-xl shadow-2xl border z-50">
                  <div className="p-3 border-b">
                    <h3 className="font-bold text-sm">الإشعارات</h3>
                  </div>
                  <div className="max-h-60 overflow-y-auto">
                    {pendingOrders.length > 0 ? (
                      pendingOrders.slice(0, 5).map((order: any) => (
                        <div
                          key={order.id}
                          className="p-3 border-b hover:bg-orange-50 cursor-pointer"
                          onClick={() => { handleNavigation('/admin/orders'); setShowNotifications(false); }}
                        >
                          <p className="text-sm font-semibold">طلب جديد #{order.orderNumber || order.id?.slice(0,8)}</p>
                          <p className="text-xs text-gray-500">{order.customerName}</p>
                          <p className="text-xs text-red-500">بانتظار تعيين سائق</p>
                        </div>
                      ))
                    ) : (
                      <div className="p-4 text-center text-gray-400 text-sm">لا توجد إشعارات</div>
                    )}
                  </div>
                </div>
              )}
            </div>
            <Sheet open={isSidebarOpen} onOpenChange={setIsSidebarOpen}>
              <SheetTrigger asChild>
                <Button variant="ghost" size="sm" className="h-9 w-9">
                  <Menu className="h-5 w-5" />
                </Button>
              </SheetTrigger>
              <SheetContent side="right" className="w-64 p-0">
                <SidebarContent />
              </SheetContent>
            </Sheet>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>

      {/* Overlay to close notifications */}
      {showNotifications && (
        <div className="fixed inset-0 z-20" onClick={() => setShowNotifications(false)} />
      )}
    </div>
  );
};
