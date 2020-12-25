[[runners]]
  name = "${name}"
  url = "${gitlab_url}"
  token = "${token}"
  executor = "${executor}"
  environment = ${environment_vars}
  pre_build_script = "${pre_build_script}"
  post_build_script = "${post_build_script}"
  pre_clone_script = "${pre_clone_script}"
  request_concurrency = ${request_concurrency}
  output_limit = ${output_limit}
  limit = ${limit}
  [runners.docker]
    tls_verify = false
    image = "${image}"
    privileged = ${privileged}
    disable_cache = false
    volumes = ["/cache"${additional_volumes}]
    shm_size = ${shm_size}
    pull_policy = "${pull_policy}"
  [runners.docker.tmpfs]
    ${volumes_tmpfs}
  [runners.docker.services_tmpfs]
    ${services_volumes_tmpfs}
  [runners.cache]
    Type = "s3"
    Shared = ${shared_cache}
    [runners.cache.s3]
      ServerAddress = "s3.amazonaws.com"
      BucketName = "${bucket_name}"
      BucketLocation = "${aws_region}"
      Insecure = false
  [runners.machine]
    IdleCount = ${idle_count}
    IdleTime = ${idle_time}
    ${max_builds}
    MachineDriver = "${machine_driver}"
    MachineName = "${machine_name}"
%{ if length(docker_machine_options) > 0 ~}
    MachineOptions = [
      %{~ for ix in range(length(docker_machine_options)) ~}
      "${docker_machine_options[ix]}"${ix < length(docker_machine_options) - 1 ? "," : ""}
      %{~ endfor ~}
    ]
%{ endif ~}
%{ for autoscaling_config in docker_machine_autoscaling ~}
%{~ if length(keys(autoscaling_config)) > 0 ~}
    [[runners.machine.autoscaling]]
    %{~ for k, v in autoscaling_config ~}
      ${k} = ${jsonencode(v)}
    %{~ endfor ~}
%{~ endif ~}
%{ endfor ~}
