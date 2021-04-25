

def foo
  @my_proc ||= Proc.new { yield }
  @my_proc.call
end

foo { puts "Hello world" } # would print "Hello world!"
foo { puts "hello again!! "}# would print "Hello world!"
