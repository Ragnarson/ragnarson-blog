desc "Start server with Thin"
task :server do
  port = ENV.fetch("PORT", 4567)
  system("thin start --chdir build --port #{port} --adapter file")
end

desc "Deploy blog"
task :deploy do
  if system("middleman build")
    system("middleman deploy")
  end
end
