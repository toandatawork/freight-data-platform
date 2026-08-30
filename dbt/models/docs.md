{% docs on_time_flag_raw %}
On-time flag **as reported by the source system**. Verified INCORRECT in 47,484 of 85,410
delivery records (55.6%) when cross-checked against actual timestamps. Use
`is_on_time_computed` instead for any analysis.
{% enddocs %}

{% docs is_on_time_computed %}
On-time flag recomputed directly from `scheduled_datetime`/`actual_datetime`. This is the
trustworthy version — `on_time_flag_raw` should only be referenced for auditing what the
source system originally reported.
{% enddocs %}

{% docs has_time_anomaly %}
True when a load's delivery timestamp precedes its pickup timestamp (486 known cases). These
loads are NOT excluded from `fct_load` — they remain visible with this flag set, and the full
detail is queryable in `qtn_time_anomaly`.
{% enddocs %}
