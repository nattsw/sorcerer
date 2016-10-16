require 'capybara'
require 'youtube-dl'

session = Capybara::Session.new(:selenium)
session.visit 'https://caster.io/login'

session.fill_in 'Username', with: 'tabby@cat.com'
session.fill_in 'Password', with: '14m4+466yc4+'
session.find('#rcp_login_submit').click

session.visit 'https://caster.io/episode-list'
links = session.find_all('.entry-content li a').map { |l| l[:href] }

links.each do |link|
  session.visit link

  script = session.find('script[type="application/ld+json"]', visible: false)
  content = JSON.parse(script.text(:all))
  video_link = content['@id']
  YoutubeDL.download(video_link)
end

