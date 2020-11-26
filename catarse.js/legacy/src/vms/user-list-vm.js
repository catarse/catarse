import m from 'mithril';
import { catarse } from '../api';
import models from '../models';

export default catarse.paginationVM(models.user, 'id.desc', { Prefer: 'count=exact' });
