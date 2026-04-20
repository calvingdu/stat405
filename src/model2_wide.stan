data {
  int<lower=1> N;
  int<lower=1> S;
  vector[N] y;
  vector[N] y_lag;
  array[N] int state_id;
  vector[N] fed_rate;
  vector[N] gdp_growth;

  int<lower=1> N_test;
  vector[N_test] y_lag_test;
  array[N_test] int state_id_test;
  vector[N_test] fed_rate_test;
  vector[N_test] gdp_growth_test;
}

parameters {
  real mu_alpha;
  real<lower=0> sigma_alpha;
  real mu_beta;
  real<lower=0> sigma_beta;
  real gamma_fed;
  real gamma_gdp;
  vector[S] alpha_raw;
  vector[S] beta_raw;
  real<lower=0> sigma;
}

transformed parameters {
  vector[S] alpha = mu_alpha + sigma_alpha * alpha_raw;
  vector[S] beta = mu_beta + sigma_beta * beta_raw;
}

model {
  mu_alpha ~ normal(5, 3);
  sigma_alpha ~ exponential(0.5);
  mu_beta ~ normal(0.5, 0.3);
  sigma_beta ~ exponential(1);
  gamma_fed ~ normal(0, 1);
  gamma_gdp ~ normal(0, 1);
  sigma ~ exponential(1);
  alpha_raw ~ normal(0, 1);
  beta_raw  ~ normal(0, 1);

  for (n in 1:N) {
    real mu = alpha[state_id[n]] + beta[state_id[n]] * y_lag[n] + gamma_fed * fed_rate[n] + gamma_gdp * gdp_growth[n];
    y[n] ~ normal(mu, sigma);
  }
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N) {
    real mu = alpha[state_id[n]] + beta[state_id[n]] * y_lag[n] + gamma_fed * fed_rate[n] + gamma_gdp * gdp_growth[n];
    y_rep[n] = normal_rng(mu, sigma);
  }

  vector[N_test] y_pred;
  for (n in 1:N_test) {
    real mu = alpha[state_id_test[n]] + beta[state_id_test[n]] * y_lag_test[n]
            + gamma_fed * fed_rate_test[n] + gamma_gdp * gdp_growth_test[n];
    y_pred[n] = normal_rng(mu, sigma);
  }
}
