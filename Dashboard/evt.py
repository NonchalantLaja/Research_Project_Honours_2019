from sklearn.preprocessing import StandardScaler
import scipy.stats
from matplotlib import style
import matplotlib.pyplot as plt
style.use('ggplot')
import seaborn as sns
import numpy as np

def evt(df):
    df.rename(columns = {'Adj.Close': 'Adj Close'}, inplace = True)
    r = df['Adj Close'].pct_change(1)

    r.dropna(inplace = True)

    fig = plt.figure(figsize = (15, 4))
    sns.distplot(r)

    plt.show() # The Dist Plot of Adj Close


    # Index array for data
    x = np.arange(len(r))
    size = len(r)

    sc = StandardScaler()
    rr = r.dropna().reshape(-1,1)
    sc.fit(rr)

    r_std = sc.transform(rr)
    r_std = r_std.flatten()
    del rr

    # List of distributions to test
    dist_names = ['genpareto', 'frechet_l', 'frechet_r', 'gumbel_l', 'gumbel_r', 'weibull_min', 'weibull_max']

    # Empty List to store results
    chi_square = []
    p_values = []

    percentile_bins = np.linspace(0,100,60)
    percentile_cutoffs = np.percentile(r_std, percentile_bins)
    observed_frequency, bins = (np.histogram(r_std, bins=percentile_cutoffs))
    cum_observed_frequency = np.cumsum(observed_frequency)

    for distribution in dist_names:
        # Set up distribution and get fitted distribution parameters
        dist = getattr(scipy.stats, distribution)
        param = dist.fit(r_std)
    
        # Obtain the Kolmogorov-Smirnov test P statistic, round it to 5 decimal places
        new_p = scipy.stats.kstest(r_std, distribution, args = param)[0]
        new_p = np.around(new_p, 5)
        p_values.append(new_p)
    
        # Get expected counts in percentile bins
        # This is based on a 'cumulative distrubution function' (cdf)
        cdf_fitted = dist.cdf(percentile_cutoffs, *param[:-2], loc=param[-2], scale=param[-1])
    
        expected_frequency = []
    
        for bin in range(len(percentile_bins)-1):
            expected_cdf_area = cdf_fitted[bin+1] - cdf_fitted[bin]
            expected_frequency.append(expected_cdf_area)
        
    
        # Calculate Chi-Squared
        expected_frequency = np.array(expected_frequency) * size
        cum_expected_frequency = np.cumsum(expected_frequency)
        ss = sum(((cum_expected_frequency - cum_observed_frequency) ** 2) / cum_observed_frequency)
        chi_square.append(ss)

    results = pd.DataFrame()
    results['Distribution'] = dist_names
    results['chi_square'] = chi_square
    results['p_value'] = p_values
    results.sort_values(['chi_square'], inplace = True)

    a = print('\nDistributions sorted by Goodness of fit:')
    b = print('----------------------------------------')
    c = print(results)
    
    return fig, a, b, c