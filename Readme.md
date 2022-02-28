# ArgoCD using Kustomize w/ Helm Charts

Kustomize Release Notes on Helm generator: https://newreleases.io/project/github/kubernetes-sigs/kustomize/release/kustomize/v4.1.0

Helm Generator options:
https://github.com/kubernetes-sigs/kustomize/blob/master/api/types/helmchartargs.go

## Helm Generator fields

| FIELD | DESCRIPTION |
|----------------------------|--------------------------------------|
|helmGlobals|Parameters applied to all Helm charts|
|helmGlobals.chartHome|Accepts a string. A file path, relative to the |Kustomization root, to a directory containing a subdirectory for each chart to be included in the Kustomization. The default value of this field is charts.|
|helmGlobals.configHome|Accepts a string. Defines a value that Kustomize should pass to Helm with the HELM_CONFIG_HOME environment variable. Kustomize doesn't attempt to read or write this directory. If omitted, TMP_DIR/helm is used, where TMP_DIR is a temporary directory created by Kustomize for Helm.|
|helmCharts|An array of Helm chart parameters|
|helmCharts.name|Accepts a string. The name of the chart. This field is required.|
|helmCharts.version|Accepts a string. The version of the chart|
|helmCharts.repo|Accepts a string. The URL used to locate the chart|
|helmCharts.releaseName|Accepts a string. Replaces RELEASE_NAME in the chart template output|
|helmCharts.namespace|Accepts a string. Sets the target namespace for a release (.Release.Namespace in the template)|
|helmCharts.valuesInline|Values to use instead of default values that accompany the chart|
|helmCharts.valuesFile|Accepts a string. ValuesFile is a local file path or a remote URL to a values file to use instead of the default values that accompanied the chart. The default values are in CHART_HOME/NAME/values.yaml.|
|helmCharts.valuesMerge|Accepts merge, override, (default), or replace. ValuesMerge specifies how to treat ValuesInline with respect to Values.|
|helmCharts.includeCRDs|Accepts true or false. Specifies if Helm should also generate CustomResourceDefinitions. The default value is false.|

You update argo-server and argocd-repo-server deploys with Docker images build from Dockerfile in this repository.

This Dockerfile is intended to update Kustomize binary version.

After this is updated you can implement the following kustomization.yaml.

``` kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
- name: helm-guestbook
  repo: https://h.cfcr.io/codefreshdemo/demo
  version: 0.1.5
  releaseName: helm-guestbook-a-dev
  namespace: dev
  valuesFile: https://raw.githubusercontent.com/dustinvanbuskirk/helm-guestbook-environments/main/helm-guestbook-a/dev/values.yaml
```

I suggest you put that in your GIT Repository for the individual microservice and you use external YAML files to reference locations of environment overrides.

If you want though putting these in some environments GIT repository and controlling them all from that repository is acceptable.

The helm generator will support bringing in common dev, staging and production values and also on a per application basis allow for application specific overwrites using valuesInline w/ inline values and valuesMerge = override which will tell the generator to overwrite the values provided on the values.yaml file where common values reside with the inline values.

Then, you use the application.yaml manifest to point to the GIT repository where the manifest for kustomization file is located.

``` application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-guestbook-a-dev
  namespace: argocd
spec:
  project: helm-guestbook-a
  source:
    repoURL: https://github.com/dustinvanbuskirk/helm-guestbook-a.git # Repository containing the Kustomization.yaml file
    targetRevision: HEAD
    path: . # Path to folder for kustomization.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
```

After setup and configuration and creating the application using the application.yaml file you can implement the workflow seen in the diagram.png of this repository.

Examples of the ci and cd pipelines are located in the GIT Repo below.
- https://github.com/dustinvanbuskirk/helm-guestbook-pipelines

Additional Resources:
- https://cloud.google.com/anthos-config-management/docs/how-to/use-repo-kustomize-helm
- https://github.com/kubernetes-sigs/kustomize/blob/master/examples/chart.md
