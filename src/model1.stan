data {
  int<lower=1> N;
  int<lower=1> S;
  vector[N] y;
  vector[N] y_lag;
  array[N] int state_id;

  int<lower=1> N_test;
  vector[N_test] y_lag_test;
  array[N_test] int state_id_test;
}

parameters {
  vector[S] alpha;
  vector[S] beta;
  real<lower=0> sigma;
}

model {
  alpha ~ normal(5, 3);
  beta ~ normal(0.5, 0.3);
  sigma ~ exponential(1);

  for (n in 1:N) {
    y[n] ~ normal(alpha[state_id[n]] + beta[state_id[n]] * y_lag[n], sigma);
  }
}

generated quantities {
  vector[N] y_rep;
  for (n in 1:N) {
    real mu = alpha[state_id[n]] + beta[state_id[n]] * y_lag[n];
    y_rep[n] = normal_rng(mu, sigma);
  }

  vector[N_test] y_pred;
  for (n in 1:N_test) {
    real mu = alpha[state_id_test[n]] + beta[state_id_test[n]] * y_lag_test[n];
    y_pred[n] = normal_rng(mu, sigma);
  }
}
