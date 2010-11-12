Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.define :user do |f|
  f.name "Foo bar"
  f.email { Factory.next(:email) }
  f.password "foobar123"
  f.password_confirmation "foobar123"
end

Factory.define :category do |f|
  f.name "Foo bar"
end

Factory.define :project do |f|
  f.name "Foo bar"
  f.association :user, :factory => :user
  f.association :category, :factory => :category
  f.video_embed '<object width="640" height="385"><param name="movie" value="http://www.youtube.com/v/20bQTYLlGQ4?fs=1&amp;hl=pt_BR"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/20bQTYLlGQ4?fs=1&amp;hl=pt_BR" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="640" height="385"></embed></object>'
end

Factory.define :backer do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.value 1.00
end

