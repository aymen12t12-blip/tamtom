import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Trash2, Edit, Ticket, Check, X, Calendar } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useToast } from '@/hooks/use-toast';
import { apiRequest } from '@/lib/queryClient';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

export default function AdminCoupons() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingCoupon, setEditingCoupon] = useState<any>(null);

  const { data: coupons, isLoading } = useQuery<any[]>({
    queryKey: ['/api/admin/coupons'],
  });

  const couponMutation = useMutation({
    mutationFn: async (data: any) => {
      if (editingCoupon) {
        return apiRequest('PUT', `/api/admin/coupons/${editingCoupon.id}`, data);
      }
      return apiRequest('POST', '/api/admin/coupons', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/admin/coupons'] });
      setIsDialogOpen(false);
      setEditingCoupon(null);
      toast({ title: editingCoupon ? "تم تحديث الكوبون" : "تم إضافة الكوبون بنجاح" });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest('DELETE', `/api/admin/coupons/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/admin/coupons'] });
      toast({ title: "تم حذف الكوبون" });
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData.entries());
    
    couponMutation.mutate({
      ...data,
      value: parseFloat(data.value as string),
      minOrderValue: parseFloat(data.minOrderValue as string || "0"),
      isActive: formData.get('isActive') === 'on',
      startDate: new Date(data.startDate as string).toISOString(),
      endDate: new Date(data.endDate as string).toISOString(),
    });
  };

  if (isLoading) return <div className="p-8 text-center">جاري التحميل...</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Ticket className="h-8 w-8 text-primary" />
          <div>
            <h1 className="text-2xl font-bold">إدارة الكوبونات</h1>
            <p className="text-muted-foreground">إنشاء وإدارة كوبونات الخصم للمتجر</p>
          </div>
        </div>
        <Button onClick={() => { setEditingCoupon(null); setIsDialogOpen(true); }} className="gap-2">
          <Plus className="h-4 w-4" /> إضافة كوبون جديد
        </Button>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table dir="rtl">
            <TableHeader>
              <TableRow>
                <TableHead className="text-right">الكود</TableHead>
                <TableHead className="text-right">النوع</TableHead>
                <TableHead className="text-right">القيمة</TableHead>
                <TableHead className="text-right">تاريخ الانتهاء</TableHead>
                <TableHead className="text-right">الحالة</TableHead>
                <TableHead className="text-left">الإجراءات</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {coupons?.map((coupon) => (
                <TableRow key={coupon.id}>
                  <TableCell className="font-bold">{coupon.code}</TableCell>
                  <TableCell>{coupon.type === 'percentage' ? 'نسبة مئوية' : 'مبلغ ثابت'}</TableCell>
                  <TableCell>{coupon.value}{coupon.type === 'percentage' ? '%' : ' ر.ي'}</TableCell>
                  <TableCell>{format(new Date(coupon.endDate), 'dd MMMM yyyy', { locale: ar })}</TableCell>
                  <TableCell>
                    {coupon.isActive ? (
                      <span className="flex items-center gap-1 text-green-600"><Check className="h-4 w-4" /> نشط</span>
                    ) : (
                      <span className="flex items-center gap-1 text-red-600"><X className="h-4 w-4" /> غير نشط</span>
                    )}
                  </TableCell>
                  <TableCell className="flex items-center gap-2">
                    <Button variant="ghost" size="sm" onClick={() => { setEditingCoupon(coupon); setIsDialogOpen(true); }}>
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="sm" className="text-red-600" onClick={() => { if(confirm('هل أنت متأكد؟')) deleteMutation.mutate(coupon.id); }}>
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[500px]" dir="rtl">
          <DialogHeader>
            <DialogTitle>{editingCoupon ? 'تعديل الكوبون' : 'إضافة كوبون جديد'}</DialogTitle>
            <DialogDescription>أدخل تفاصيل الكوبون أدناه</DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="code">كود الخصم</Label>
                <Input id="code" name="code" defaultValue={editingCoupon?.code} required placeholder="مثلاً: RAMADAN2024" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="type">النوع</Label>
                <Select name="type" defaultValue={editingCoupon?.type || 'percentage'}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="percentage">نسبة مئوية</SelectItem>
                    <SelectItem value="fixed">مبلغ ثابت</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="value">القيمة</Label>
                <Input id="value" name="value" type="number" defaultValue={editingCoupon?.value} required />
              </div>
              <div className="space-y-2">
                <Label htmlFor="minOrderValue">الحد الأدنى للطلب</Label>
                <Input id="minOrderValue" name="minOrderValue" type="number" defaultValue={editingCoupon?.minOrderValue} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="startDate">تاريخ البدء</Label>
                <Input id="startDate" name="startDate" type="date" defaultValue={editingCoupon?.startDate?.split('T')[0]} required />
              </div>
              <div className="space-y-2">
                <Label htmlFor="endDate">تاريخ الانتهاء</Label>
                <Input id="endDate" name="endDate" type="date" defaultValue={editingCoupon?.endDate?.split('T')[0]} required />
              </div>
            </div>
            <div className="flex items-center justify-between">
              <Label htmlFor="isActive">نشط</Label>
              <Switch id="isActive" name="isActive" defaultChecked={editingCoupon?.isActive !== false} />
            </div>
            <DialogFooter>
              <Button type="submit" className="w-full" disabled={couponMutation.isPending}>
                {editingCoupon ? 'حفظ التغييرات' : 'إضافة الكوبون'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
