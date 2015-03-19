Puppet::Parser::Functions.newfunction(:generate_nagios_instances, :type => :rvalue) do |args|
  checks_dict = args[0]
  types_dict = args[1]
  nodes_dict = args[2]
  existing_instances = args[3]

  existing_instances = {} if existing_instances= ""
  new_instances = Hash.new
  nodes_dict.each do |hostname, node|
    node_type = node["type"]
    check_list = types_dict[node_type]
    check_list.each do |check_name|
      check = checks_dict[check_name]
      new_check = Hash.new
      new_check["name"] = check_name
      new_check["check_command"] = check["check_command"].sub! '<host>', hostname
      new_check["host_name"] = hostname
      new_check["check_interval"] = check["check_interval"] if check.has_key?("check_interval")
      if check.has_key?("dimensions") and node.has_key("dimensions")
        new_check["dimensions"] = node["dimensions"].merge(check["dimensions"])
      elsif check.has_key?("dimensions")
        new_check["dimensions"] = check["dimensions"]
      elsif node.has_key?("dimensions")
        new_check["dimensions"] = node["dimensions"]
      end
      check_name = "#{check_name}_#{hostname}"
      new_instances[check_name] = new_check
    end
  end
  instances = existing_instances.merge(new_instances)
end