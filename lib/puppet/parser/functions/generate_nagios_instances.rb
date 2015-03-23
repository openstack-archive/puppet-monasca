Puppet::Parser::Functions.newfunction(:generate_nagios_instances, :type => :rvalue) do |args|
  checks_dict = args[0]
  nodes_dict = args[1]
  dimensions_dict = args[2]
  flags_dict = args[3]
  existing_instances = args[4]

  existing_instances = {} if existing_instances= ""
  dimensions_dict = {} if dimensions_dict= ""
  flags_dict = {} if flags_dict= ""
  new_instances = Hash.new
  nodes_dict.each do |groupname, nodes|
    group_dimensions = {}
    group_dimensions = dimensions_dict[groupname] if dimensions_dict.has_key?(groupname)
    next if not flags_dict.has_key?(groupname)
    group_flags = flags_dict[groupname]
    nodes.each do |hostname|
      next if not group_flags.has_key?("type")
      node_type = group_flags["type"]
      check_list = types_dict[node_type]
      check_list.each do |check_name|
        check = checks_dict[check_name]
        new_check = Hash.new
        new_check["name"] = check_name
        new_command = check["check_command"]
        group_dimensions.each do |key, value|
          to_sub = '<'
          to_sub << key
          to_sub << '>'
          new_command = new_command.sub to_sub, value
        end
        group_flags.each do |key, value|
          to_sub = '<'
          to_sub << key
          to_sub << '>'
          new_command = new_command.sub to_sub, value
        end
        new_check["check_command"] = new_command.sub '<host>', hostname
        new_check["host_name"] = hostname
        new_check["check_interval"] = check["check_interval"] if check.has_key?("check_interval")
        if check.has_key?("dimensions")
          new_check["dimensions"] = group_dimensions.merge(check["dimensions"])
        else
          new_check["dimensions"] = group_dimensions
        end
        check_name = "#{check_name}_#{hostname}"
        new_instances[check_name] = new_check
      end
    end
  end
  instances = existing_instances.merge(new_instances)
end