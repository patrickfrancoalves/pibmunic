#from sklearn_extensions.extreme_learning_machines.elm import ELMClassifier, ELMRegressor, GenELMClassifier, GenELMRegressor
#from sklearn_extensions.extreme_learning_machines.random_layer import RBFRandomLayer, MLPRandomLayer, GRBFRandomLayer, RandomLayer

from elmx import ELMClassifier, ELMRegressor, GenELMClassifier, GenELMRegressor
from random_layer import RBFRandomLayer, MLPRandomLayer, GRBFRandomLayer, RandomLayer

__all__ = [
    'ELMRegressor',
    'ELMClassifier',
    'GenELMRegressor',
    'GenELMClassifier',
    'RandomLayer',
    'GRBFRandomLayer',
    'RBFRandomLayer',
    'MLPRandomLayer'
]