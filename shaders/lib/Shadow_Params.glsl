const float ambientOcclusionLevel = 0.0; //[0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0 ]
const float	sunPathRotation	= -35;	//[-90 -89 -88 -87 -86 -85 -84 -83 -82 -81 -80 -79 -78 -77 -76 -75 -74 -73 -72 -71 -70 -69 -68 -67 -66 -65 -64 -63 -62 -61 -60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50 -49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33 -32 -31 -30 -29 -28 -27 -26 -25 -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 ]

const int shadowMapResolution = 3172; //Will probably crash at 16 384 [512 768 1024 1536 2048 3172 4096 8192 16384]
const float shadowDistance = 150;		//[32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 ] Not linear at all when shadowDistanceRenderMul is set to -1.0, 175.0 is enough for 40 render distance
const float shadowDistanceRenderMul = -1.0; //[-1.0 1.0] Can help to increase shadow draw distance when set to -1.0, at the cost of performance

#define Variable_Penumbra_Shadows	//Makes the shadows more blurry the more distant they are to objects (costs fps)
#define VPS_Search_Samples 4 //The number of samples used to find occluders [4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]
#define Min_Shadow_Filter_Radius 1.0	//If Variable_Penumbra_Shadows are not used, will be used as shadow filter size. [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0 31.0 32.0 33.0 34.0 35.0 36.0 37.0 38.0 39.0 40.0 41.0 42.0 43.0 44.0 45.0 46.0 47.0 48.0 49.0 50.0 51.0 52.0 53.0 54.0 55.0 56.0 57.0 58.0 59.0 60.0 61.0 62.0 63.0 64.0 65.0 66.0 67.0 68.0 69.0 70.0 71.0 72.0 73.0 74.0 75.0 76.0 77.0 78.0 79.0 80.0 81.0 82.0 83.0 84.0 85.0 86.0 87.0 88.0 89.0 90.0 91.0 92.0 93.0 94.0 95.0 96.0 97.0 98.0 99.0 100.0 101.0 102.0 103.0 104.0 105.0 106.0 107.0 108.0 109.0 110.0 111.0 112.0 113.0 114.0 115.0 116.0 117.0 118.0 119.0 ]
#define Max_Shadow_Filter_Radius 10.0  //Not used if Variable_Penumbra_Shadows are not used. Will cause issues at too high values [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0 31.0 32.0 33.0 34.0 35.0 36.0 37.0 38.0 39.0 40.0 41.0 42.0 43.0 44.0 45.0 46.0 47.0 48.0 49.0 50.0 51.0 52.0 53.0 54.0 55.0 56.0 57.0 58.0 59.0 60.0 61.0 62.0 63.0 64.0 65.0 66.0 67.0 68.0 69.0 70.0 71.0 72.0 73.0 74.0 75.0 76.0 77.0 78.0 79.0 80.0 81.0 82.0 83.0 84.0 85.0 86.0 87.0 88.0 89.0 90.0 91.0 92.0 93.0 94.0 95.0 96.0 97.0 98.0 99.0 100.0 101.0 102.0 103.0 104.0 105.0 106.0 107.0 108.0 109.0 110.0 111.0 112.0 113.0 114.0 115.0 116.0 117.0 118.0 119.0 ]
#define Max_Filter_Depth 20.0 //Distance to the occluder at which the shadow filter size reaches its maximum. [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0 31.0 32.0 33.0 34.0 35.0 36.0 37.0 38.0 39.0 40.0 41.0 42.0 43.0 44.0 45.0 46.0 47.0 48.0 49.0 50.0 51.0 52.0 53.0 54.0 55.0 56.0 57.0 58.0 59.0 60.0 61.0 62.0 63.0 64.0 65.0 66.0 67.0 68.0 69.0 70.0 71.0 72.0 73.0 74.0 75.0 76.0 77.0 78.0 79.0 80.0 81.0 82.0 83.0 84.0 85.0 86.0 87.0 88.0 89.0 90.0 91.0 92.0 93.0 94.0 95.0 96.0 97.0 98.0 99.0 100.0 101.0 102.0 103.0 104.0 105.0 106.0 107.0 108.0 109.0 110.0 111.0 112.0 113.0 114.0 115.0 116.0 117.0 118.0 119.0 ]
#define SCREENSPACE_CONTACT_SHADOWS	//Raymarch towards the sun in screen-space, in order to cast shadows outside of the shadow map or at the contact of objects. Can get really expensive at high resolutions.
#define SHADOW_FILTER_SAMPLE_COUNT 6 // Number of samples used to filter the actual shadows [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 ]

#define SSGI

#define ssgi_staturation
#define ssgi_temporal
//#define ssgi_ext


#define SSPTMIX1 1.0 //[0.0 0.001 0.01 0.015 0.025 0.05 0.1 0.125 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.9 1.0]
#define SSPTambient 1.0 // [0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.20 0.22 0.23 0.25 0.27 0.29 0.32 0.34 0.37 0.40 0.43 0.46 0.50 0.54 0.58 0.63 0.68 0.74 0.79 0.86 0.93 1.00 1.08 1.17 1.26 1.36 1.47 1.59 1.71 1.85 2.00 2.16 2.33 2.51 2.72 2.93 3.17 3.42 3.69 3.99 4.30 4.65 5.02 5.42 5.85 6.32 6.82 7.37 7.95 8.59 9.27 10.01 10.81 11.68 12.61 13.61 14.70 15.87 17.14 18.51 19.99 21.58 23.30 25.16 27.17 29.34 31.68 34.21 36.94 39.89 43.07 46.50 50.22 54.22 58.55 63.22 68.27 73.72 79.60 85.95 92.81 100.22 108.21 116.85 126.17 136.24 147.11 158.85 171.53 185.22 200.00]
#define SSPTweightmix 0.25 // [0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.20 0.22 0.23 0.25 0.27 0.29 0.32 0.34 0.37 0.40 0.43 0.46 0.50 0.54 0.58 0.63 0.68 0.74 0.79 0.86 0.93 1.00 1.08 1.17 1.26 1.36 1.47 1.59 1.71 1.85 2.00 2.16 2.33 2.51 2.72 2.93 3.17 3.42 3.69 3.99 4.30 4.65 5.02 5.42 5.85 6.32 6.82 7.37 7.95 8.59 9.27 10.01 10.81 11.68 12.61 13.61 14.70 15.87 17.14 18.51 19.99 21.58 23.30 25.16 27.17 29.34 31.68 34.21 36.94 39.89 43.07 46.50 50.22 54.22 58.55 63.22 68.27 73.72 79.60 85.95 92.81 100.22 108.21 116.85 126.17 136.24 147.11 158.85 171.53 185.22 200.00]



#define RAY_COUNT 2 // [1 2 3 4 5 6 7 8 9 10 12 14 16 18 21 24 28 32 37 43 49 57 65 75 86 100]
#define STEPS 6	// [ 6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99]
#define STEP_LENGTH 60.	// [ 4.  5.  6.  7.  8.  9. 10. 11. 12. 13. 14. 15. 16. 17. 18. 19. 20. 21. 22. 23. 24. 25. 26. 27. 28. 29. 30. 60. 90.]
#define SubSurfaceScattering

const float k = 1.8;
const float d0 = 0.04;
const float d1 = 0.61;
float a = exp(d0);
float b = (exp(d1)-a)*shadowDistance/128.0;

//method based on code from robobo1221
#define shadowmapBias 0.85


float getWarpFactor(in vec2 x) {
//      return log(length(x)*b+a)*k;
        return length(x * 1.169) * shadowmapBias + (1.0 - shadowmapBias);
}


vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition) {

  float distortFactor = getWarpFactor(projectedShadowSpacePosition.xy);
  projectedShadowSpacePosition.xy /= distortFactor;
  return projectedShadowSpacePosition;
}


float calcDistort(vec2 worldpos){
  return 1.0/getWarpFactor(worldpos.xy);
}
