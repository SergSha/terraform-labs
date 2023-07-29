
[all]
%{ for master in masters ~}
${ master["domain_name"] } ansible_host=${ master["network_address"] }
%{ endfor ~}
%{ for node in nodes ~}
${ node["domain_name"] } ansible_host=${ node["network_address"] }
%{ endfor ~}

[kube_control_plane]
%{ for master in masters ~}
${ master["domain_name"] }
%{ endfor ~}

[etcd]
%{ for master in masters ~}
${ master["domain_name"] }
%{ endfor ~}

[kube_node]
%{ for node in nodes ~}
${ node["domain_name"] }
%{ endfor ~}

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr

