#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import json

dir = os.path.split(os.path.realpath(__file__))[0]

def LoadData(j='indicator_data_categorical_assessment.json', verbose=True):
  '''Load configuration parameters.'''
  
  data_dir = os.path.join(os.path.split(dir)[0], 'data')

  try:
    j = os.path.join(data_dir, j)
    with open(j) as json_file:    
      config = json.load(json_file)

  except Exception as e:
    print "Couldn't load configuration."
    if verbose:
      print e
    return False

  return config



def CheckData(data, indicator, country):
  '''Checking data.'''

  indicators = data['Indicator']
  countries = [ key for key in data.keys() if key != 'Indicator' ]
  
  if indicator not in indicators:
    print 'Indicator not in data'
    return False

  if country not in countries:
    print 'Country not in data.'
    return False
  
  #
  # Selecting data.
  #
  i = indicators.index(indicator) 
  country_data = data[country]
  category = country_data[i]
  categories = {
    '1': 'No data',
    '2': 'National',
    '3': 'Partial',
    '4': 'Complete'
  }
  print 'Data found for %s in country %s: %s' % (indicator, country, categories[str(category)])






if __name__ == "__main__":
  data = LoadData()
  CheckData(data = data, indicator = "Human Development Index", country = 'Rwanda')