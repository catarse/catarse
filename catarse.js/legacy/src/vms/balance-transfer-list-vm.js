import m from 'mithril';
import { catarse } from '../api';
import models from '../models';

export default catarse.paginationVM(models.balanceTransfer, 'created_at.asc', { Prefer: 'count=exact' });
