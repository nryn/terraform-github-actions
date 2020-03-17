# Terraform Graph

Generate a DOT-format text file, for the puposes of creating a visual representation of either a configuration or execution plan.

```yaml
name: "Terraform GitHub Actions"
on:
  - push
jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    steps:
      - name: "Checkout"
        uses: actions/checkout@master
      - name: "Terraform Init"
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version: 0.12.13
          tf_actions_subcommand: "init"
          tf_actions_working_dir: "."
          tf_actions_comment: true
        env:
          TF_WORKSPACE: dev
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: "Terraform Graph"
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version: 0.12.13
          tf_actions_subcommand: "graph"
          tf_actions_working_dir: "."
          tf_actions_comment: true
          tf_actions_graph_output_file: "./graphfile"
          args: "-type=plan"
        env:
          TF_WORKSPACE: dev
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
