# Parallel Limit
# =================================================
# Helper to get default calculation for maximum parallel runs in asynchronous mode
# centralized for all modules.


# Node Modules
# -------------------------------------------------
posix = require 'posix'


# Setup
# ------------------------------------------------
# Maximum parallel processes is half of the soft limit for open files if not given
# in the options.
PARALLEL = Math.floor posix.getrlimit('nofile').soft / 2


# External Methods
# -------------------------------------------------


# @param {Object} options to check for predefined `parallel` setting
# @return {Integer} number of may allowed parallel runs
module.exports = (options) -> options.parallel ? PARALLEL
