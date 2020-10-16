import mq from 'mithril-query';
import m from 'mithril';
import _ from 'underscore';
import postEntry from '../../src/c/post-entry';
import h from '../../src/h';

describe('PostEntry', () => {

    describe('view', () => {
        let $postEntry, $mocked;
        beforeAll(() => {
            $mocked = _.first(PostEntryMockery())
            $postEntry = mq(m(postEntry, $mocked))
        })

        it('Should get post title', () => {
            expect($postEntry.contains($mocked.post.title)).toBeTrue()
        })

        it('Should get post created date', () => {
            expect($postEntry.contains(h.momentify($mocked.post.created_at, 'DD/MM/YYYY, h:mm A'))).toBeTrue()
        })

        it('Should get project post url', () => {
            const post_link = `/projects/${$mocked.project.project_id}/posts/${$mocked.post.id}#posts`
            expect($postEntry.first('a.alt-link.fontsize-base').attrs.href).toEqual(post_link)
        })

        it('Should click to delete this post', () => {
            $postEntry.click('button.btn.btn-no-border.btn-small.btn-terciary.fa.fa-lg.fa-trash')
            expect($mocked.clicked_to_delete).toBeTrue()
        })
    })
})
