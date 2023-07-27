
[all]
%{ for master in masters ~}
${ master["domain_name"] } ansible_host=${ master["network_address"] }
%{ endfor ~}
%{ for node in nodes ~}
${ node["domain_name"] } ansible_host=${ node["network_address"] }
%{ endfor ~}

