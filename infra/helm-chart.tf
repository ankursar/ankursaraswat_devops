resource "null_resource" "HelmChart-Deployment" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.pip.ip_address
    user     = var.vm_username
    password = azurerm_key_vault_secret.vm-secret.value
  }
  provisioner "file" {
    source      = "../app/bundle/webapp.tar.gz"
    destination = "/home/vmadmin/webapp.tar.gz"
  }
  provisioner "remote-exec" {
    inline = [
      "export KUBECONFIG=/home/vmadmin/.kube/config",
      "helm uninstall webapp -n webapp",
      "kubectl delete namespace webapp",
      "kubectl create namespace webapp --kubeconfig /home/vmadmin/.kube/config",
      "helm install webapp ./webapp.tar.gz --namespace webapp"
    ]
  }
  depends_on = [null_resource.HelmChart-Install]
}