#
# (C) Copyright 2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
#

import click
from netCDF4 import Dataset
import numpy as np

# --------------------------------------------------------------------------------------------------
## @package generate_akbk
#  This function generates a netCDF file containing ak/bk for reading the fv3-jedi Geometry
#
#  Current options:
#  64:   # gfs <= v15
#  72:   # geos
#  127:  # gfs >= 16
#
# --------------------------------------------------------------------------------------------------

def abort(message):
    print('\n ABORT: '+message+'\n')
    raise(SystemExit)

# --------------------------------------------------------------------------------------------------

@click.command()
@click.option('--levels', required=True, help='Number of model levels', type=int)
def main(levels):

  # Print
  print('\n Running generate_akbk with \''+str(levels)+'\' levels.')

  # Supported options
  levels_avail = [64, 72, 127]

  # Check for sensible input
  if not levels in levels_avail:
    abort('Number of levels \''+str(levels)+'\' not available')

  if levels == 64:
    # GFS 64 level model, GFS v15
    ak = [20.0, 64.247, 137.79, 221.958, 318.266, 428.434, 554.424, 698.457, 863.058,
          1051.08, 1265.752, 1510.711, 1790.051, 2108.366, 2470.788, 2883.038,
          3351.46, 3883.052, 4485.493, 5167.146, 5937.05, 6804.874, 7777.15,
          8832.537, 9936.614, 11054.85, 12152.94, 13197.07, 14154.32, 14993.07,
          15683.49, 16197.97, 16511.74, 16611.6, 16503.14, 16197.32, 15708.89,
          15056.34, 14261.43, 13348.67, 12344.49, 11276.35, 10171.71, 9057.051,
          7956.908, 6893.117, 5884.206, 4945.029, 4086.614, 3316.217, 2637.553,
          2051.15, 1554.789, 1143.988, 812.489, 552.72, 356.223, 214.015, 116.899,
          55.712, 21.516, 5.741, 0.575, 0.0, 0.0]
    bk = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          3.697e-05, 0.00043106, 0.00163591, 0.00410671, 0.00829402, 0.01463712,
          0.02355588, 0.03544162, 0.05064684, 0.06947458, 0.09216691, 0.1188122,
          0.1492688, 0.1832962, 0.2205702, 0.2606854, 0.3031641, 0.3474685,
          0.3930182, 0.4392108, 0.4854433, 0.5311348, 0.5757467, 0.6187996,
          0.659887, 0.6986829, 0.7349452, 0.7685147, 0.7993097, 0.8273188,
          0.8525907, 0.8752236, 0.895355, 0.913151, 0.9287973, 0.9424911,
          0.9544341, 0.9648276, 0.9738676, 0.9817423, 0.9886266, 0.9946712, 1]
  elif levels == 72:
    # GEOS 72 level model
    ak = [1, 2.00000023841858, 3.27000045776367, 4.75850105285645, 6.60000133514404,
          8.93450164794922, 11.9703016281128, 15.9495029449463, 21.1349029541016, 27.8526058197021,
          36.5041084289551, 47.5806083679199, 61.6779098510742, 79.5134124755859, 101.944023132324,
          130.051025390625, 165.079025268555, 208.497039794922, 262.021057128906, 327.64306640625,
          407.657104492188, 504.680114746094, 621.680114746094, 761.984191894531, 929.294189453125,
          1127.69018554688, 1364.34020996094, 1645.71032714844, 1979.16040039062, 2373.04052734375,
          2836.78051757812, 3381.00073242188, 4017.541015625, 4764.39111328125, 5638.791015625,
          6660.34130859375, 7851.2314453125, 9236.572265625, 10866.3017578125, 12783.703125,
          15039.302734375, 17693.00390625, 20119.201171875, 21686.501953125, 22436.30078125,
          22389.80078125, 21877.59765625, 21214.998046875, 20325.8984375, 19309.6953125,
          18161.896484375, 16960.896484375, 15625.99609375, 14290.9951171875, 12869.59375,
          11895.8623046875, 10918.1708984375, 9936.521484375, 8909.9921875, 7883.421875,
          7062.1982421875, 6436.263671875, 5805.3212890625, 5169.61083984375, 4533.90087890625,
          3898.20092773438, 3257.08081054688, 2609.20068359375, 1961.310546875, 1313.48034667969,
          659.375244140625, 4.80482578277588, 0]
    bk = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8.17541323527848e-09, 0.00696002459153533,
          0.0280100405216217, 0.0637200623750687, 0.113602079451084, 0.156224086880684,
          0.200350105762482, 0.246741116046906, 0.294403105974197, 0.343381136655807,
          0.392891138792038, 0.44374018907547, 0.494590193033218, 0.546304166316986,
          0.581041514873505, 0.615818440914154, 0.650634944438934, 0.685899913311005,
          0.721165955066681, 0.749378204345703, 0.770637512207031, 0.791946947574615,
          0.81330394744873, 0.834660947322845, 0.856018006801605, 0.877429008483887,
          0.898908019065857, 0.920387029647827, 0.941865026950836, 0.963406026363373,
          0.984951972961426, 1]
  elif levels == 127:
    # GFS 127 level model
    ak = [0.999, 1.605, 2.532, 3.924, 5.976, 8.947, 13.177, 19.096, 27.243, 38.276, 52.984,
          72.293, 97.269, 129.11, 169.135, 218.767, 279.506, 352.894, 440.481, 543.782, 664.236,
          803.164, 961.734, 1140.931, 1341.538, 1564.119, 1809.028, 2076.415, 2366.252, 2678.372,
          3012.51, 3368.363, 3745.646, 4144.164, 4563.881, 5004.995, 5468.017, 5953.848, 6463.864,
          7000, 7563.494, 8150.661, 8756.529, 9376.141, 10004.553, 10636.851, 11268.157, 11893.639,
          12508.519, 13108.091, 13687.727, 14242.89, 14769.153, 15262.202, 15717.859, 16132.09,
          16501.018, 16820.938, 17088.324, 17299.852, 17453.084, 17548.35, 17586.771, 17569.697,
          17498.697, 17375.561, 17202.299, 16981.137, 16714.504, 16405.02, 16055.485, 15668.86,
          15248.247, 14796.868, 14318.04, 13815.15, 13291.629, 12750.924, 12196.468, 11631.659,
          11059.827, 10484.208, 9907.927, 9333.967, 8765.155, 8204.142, 7653.387, 7115.147,
          6591.468, 6084.176, 5594.876, 5124.949, 4675.554, 4247.633, 3841.918, 3458.933, 3099.01,
          2762.297, 2448.768, 2158.238, 1890.375, 1644.712, 1420.661, 1217.528, 1034.524, 870.778,
          725.348, 597.235, 485.392, 388.734, 306.149, 236.502, 178.651, 131.447, 93.74, 64.392,
          42.274, 26.274, 15.302, 8.287, 4.19, 1.994, 0.81, 0.232, 0.029, 0, 0, 0]
    bk = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.018e-05, 8.141e-05, 0.00027469, 0.00065078, 0.00127009,
          0.00219248, 0.00347713, 0.00518228, 0.00736504, 0.0100812, 0.01338492, 0.01732857,
          0.02196239, 0.02733428, 0.03348954, 0.04047056, 0.04831661, 0.05706358, 0.06674372,
          0.07738548, 0.08900629, 0.10159397, 0.11512618, 0.12957622, 0.14491294, 0.1611008,
          0.17809989, 0.19586605, 0.21435112, 0.23350307, 0.25326633, 0.27358216, 0.29438898,
          0.3156229, 0.33721805, 0.35910723, 0.38122237, 0.40349507, 0.42585716, 0.44824126,
          0.47058126, 0.49281296, 0.51487434, 0.53670621, 0.55825245, 0.5794605, 0.60028154,
          0.62067074, 0.64058751, 0.65999568, 0.67886335, 0.69716311, 0.714872, 0.73197126,
          0.74844646, 0.76428711, 0.77948666, 0.79404217, 0.80795413, 0.8212263, 0.83386517,
          0.84588009, 0.85728264, 0.86808664, 0.8783077, 0.88796324, 0.89707178, 0.90565324,
          0.91372836, 0.92131871, 0.92844635, 0.93513376, 0.94140369, 0.94727886, 0.95278209,
          0.95793599, 0.96276295, 0.9672851, 0.971524, 0.97550088, 0.97923642, 0.98275077,
          0.98606253, 0.98918509, 0.99212992, 0.99490768, 0.9975282, 1]

  # Sanity checks
  # -------------
  if not len(ak) == len(bk):
    abort('Length of ak does not match length of bk')

  if not len(ak) == levels+1:
    abort('Length of ak/bk does not match chosen number of levels')

  # Print information
  # -----------------
  print('\n ak = ', ak)
  print('\n bk = ', ak)
  print('\n ')

  # Write to netCDF file
  # --------------------
  filename = 'akbk'+str(levels)+'_testing.nc4'

  ncfile = Dataset(filename, mode='w')

  # Create dimensions
  ncfile.createDimension('edges', levels+1)

  # Meta
  ncfile.title='ak and bk for hybrid sigma-pressure fv3 model with '+str(levels)+' levels. P = ak + bkPs'

  # Variables
  ak_id = ncfile.createVariable('ak', np.float64, ('edges',))
  ak_id.units = 'Pa'
  ak_id[:] = ak

  bk_id = ncfile.createVariable('bk', np.float64, ('edges',))
  bk_id.units = '1'
  bk_id[:] = bk

  # Close
  ncfile.close()

# --------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    main()

# --------------------------------------------------------------------------------------------------
