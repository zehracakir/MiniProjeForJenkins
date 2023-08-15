# .NET WEB API

Bu repository DevOps staj sürecim boyunca geliştirdiğim mini projeyi içermektedir.

# Proje Hakkında

İlk olarak .Net ile bir Web API projesi oluşturdum. 

- Swagger ekran görüntüsü

![Untitled](/photos/swagger_ss.png)

- Bir Dockerfile oluşturdum ve build edip image haline getirip Docker Hub’da paylaştım.

Docker Hub Linki : [https://hub.docker.com/r/zehracakir/mini_proje](https://hub.docker.com/r/zehracakir/mini_proje)

Dockerfile içeriği :

![Untitled](/photos/dockerfile_ss.png)

Daha sonra projemde kubernetes kullanarak env’leri config-map dosyamda tuttum.

![Untitled](/photos/dockerfile_env_ss.png)

![Untitled](/photos/configmap_ss.png)

Bu config-map’teki env’leri kullanabilmek için deploy dosyamda config-map’i çağırdım.

![Untitled](/photos/deploy_ss.png)

Dosyaları tek tek çalıştırmak yerine bir kustomization.yaml oluşturdum.

![Untitled](/photos/kustomization_ss.png)

Jenkinsfile kısmında ise bir pipeline oluşturdum. Kubernetes içinde bir Jenkins ajanı oluşturdum ve burada ajana bir pod oluşturttum. Test aşamasında Github adresimden main dalındaki projemi indirdim. Build-Docker-Image kısmında Docker Image’ını Github depomdan aldığı belirli bir commit ID’sini tag olarak ekleyip build ettim. Run aşamasında Docker Hub’a giriş yaptım ve commit Id’sini tag olarak verilen image’ı pushladım. Test etmek içib image’ı çalıştırdım. Kubernetes deploy dosyamdaki image tag’ini güncelledim ve değişiklikleri uyguladım. 

```bash
pipeline {
  agent {
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      metadata:
        name: jenkins-agent
      spec:
        serviceAccountName: internal-kubectl
        containers:
        - name: jenkins-agent
          image: zehracakir/jenkins-agent:1.0
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        volumes:
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
        '''
    }
  }
  stages {
    stage('Test') {
      steps {
          container('jenkins-agent') {
        git branch: 'main', url: 'https://github.com/zehracakir/MiniProjeForJenkins.git'
        }
      } 
      }
    
    stage('Build-Docker-Image') {
      steps {
        container('jenkins-agent') {
           sh 'git config --global --add safe.directory "*"'
           sh 'gitRevisionId=`git rev-parse HEAD`; docker build -t zehracakir/mini_proje:${gitRevisionId} .'
        }
      }
    }
    stage('Run') {
      steps {
        container('jenkins-agent') {
          sh 'git config --global --add safe.directory "*"'
          sh 'gitRevisionId=`git rev-parse HEAD`'
          sh 'docker login -u zehracakir -p password'
          sh 'gitRevisionId=`git rev-parse HEAD`; docker push zehracakir/mini_proje:${gitRevisionId}'
          sh 'gitRevisionId=`git rev-parse HEAD`; docker run -d zehracakir/mini_proje:${gitRevisionId}'
        }
    }
}
  stage('Kubectl') {
      steps {
        container('jenkins-agent') {
        sh 'git config --global --add safe.directory "*"'
        sh 'gitRevisionId=`git rev-parse HEAD`; sed -i "s,zehracakir/mini-proje:git-mini-proje-tag,zehracakir/mini_proje:${gitRevisionId},g" manifest/mini_proje_deploy.yaml'
        sh 'kubectl apply -k manifest/'
        }
      }
    }
  }
  }
```

Kubernetes, git ve docker’ı tek bir image halinde Docker Hub’a yolladım. Image linki : [https://hub.docker.com/r/zehracakir/jenkins-agent](https://hub.docker.com/r/zehracakir/jenkins-agent)