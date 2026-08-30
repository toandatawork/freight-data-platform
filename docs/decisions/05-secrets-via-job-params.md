# 005. Secrets via Job Parameters

## Context

Databricks Ingestion Jobs need PostgreSQL credentials to pull raw data into Bronze. We had to choose between Databricks Secret Scopes and Job parameters.

## Decision

Pass credentials via `dbutils.widgets` (Job base parameters) rather than setting up Databricks Secret Scopes.

## Trade-offs

| Pros                                                                                           | Cons                                             |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| Faster local setup without extra CLI configuration or ACL management for a portfolio showcase. | Passwords appear in Job run parameter histories. |

## Consequences

This is an intentional trade-off for a portfolio demonstration. In a real production deployment, credentials must be migrated to Azure Key Vault or AWS Secrets Manager via Databricks Secret Scopes.
