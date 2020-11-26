import mq from 'mithril-query';
import usersShow from '../../../src/root/users-show';

describe('UsersShow', () => {
  let $output, userDetail;

  beforeAll(() => {
    window.location.hash = '';
    userDetail = UserDetailMockery()[0];
    userDetail.user_id = `${userDetail.user_id}`;
    userDetail.user_details = userDetail;
    $output = mq(m(usersShow, userDetail));
  });

  it('should render some user details', () => {
    $output.should.have('#contributed_link');
    $output.should.have('#created_link');
    $output.should.have('#about_link');
    
    expect($output.contains(userDetail.name)).toEqual(true);
  });
});
