test_name "should update an entry for an SSH authorized key"

confine :except, :platform => ['windows']

auth_keys = '~/.ssh/authorized_keys'
name = "pl#{rand(999999).to_i}"

agents.each do |agent|
  teardown do
    #(teardown) restore the #{auth_keys} file
    on(agent, "mv /tmp/auth_keys #{auth_keys}", :acceptable_exit_codes => [0,1])
  end

  #------- SETUP -------#
  step "(setup) backup #{auth_keys} file"
  on(agent, "cp #{auth_keys} /tmp/auth_keys", :acceptable_exit_codes => [0,1])

  step "(setup) create an authorized key in the #{auth_keys} file"
  on(agent, "echo 'ssh-rsa mykey #{name}' >> #{auth_keys}")

  #------- TESTS -------#
  step "update an authorized key entry with puppet (present)"
  args = ['ensure=present',
          "user='root'",
          "type='rsa'",
          "key='mynewshinykey'",
         ]
  on(agent, puppet_resource('ssh_authorized_key', "#{name}", args))

  step "verify entry updated in #{auth_keys}"
  on(agent, "cat #{auth_keys}")  do |res|
    fail_test "didn't find the updated key for #{name}" unless stdout.include? "mynewshinykey #{name}"
  end

end
