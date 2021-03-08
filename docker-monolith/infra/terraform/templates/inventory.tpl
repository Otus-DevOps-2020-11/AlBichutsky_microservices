[docker_hosts]
%{ for ip in app_hosts ~}
${ip}
%{ endfor ~}
