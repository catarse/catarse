import h from '../h';
import { commonPayment } from '../api';
import models from '../models';

export const getPaymentsListVM = () => {
    const listVM = commonPayment.paginationVM(models.commonPayments, 'created_at.desc', { Prefer: 'count=exact' });
    return h.createBasicPaginationVMWithAutoRedraw(listVM);
}