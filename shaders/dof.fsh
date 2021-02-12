#version 130
//Vignetting, applies bloom, applies exposure and tonemaps the final image
#extension GL_EXT_gpu_shader4 : enable
#define Fake_purkinje

#define BLOOMY_FOG 0.5 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 6.0 10.0 15.0 20.0]
#define BLOOM_STRENGTH  1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0]
#define TONEMAP Tonemap_Loop // Tonemapping operator [ HableTonemap reinhard Tonemap_Lottes ACESFilm ToneMap_Hejl2015]
//#define USE_ACES_COLORSPACE_APPROXIMATION	// Do the tonemap in another colorspace

#define Purkinje_strength 1.0	// Simulates how the eye is unable to see colors at low light intensities. 0 = No purkinje effect at low exposures [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]

#define Purkinje_R 0.4 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_G 0.7 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_B 1.0 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]



#define Purkinje_Multiplier 5.0 // How much the purkinje effect increases brightness [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3.0 3.05 3.1 3.15 3.2 3.25 3.3 3.35 3.4 3.45 3.5 3.55 3.6 3.65 3.7 3.75 3.8 3.85 3.9 3.95 4.0 4.05 4.1 4.15 4.2 4.25 4.3 4.35 4.4 4.45 4.5 4.55 4.6 4.65 4.7 4.75 4.8 4.85 4.9 4.95 5.0 5.05 5.1 5.15 5.2 5.25 5.3 5.35 5.4 5.45 5.5 5.55 5.6 5.65 5.7 5.75 5.8 5.85 5.9 5.95 6.0 6.05 6.1 6.15 6.2 6.25 6.3 6.35 6.4 6.45 6.5 6.55 6.6 6.65 6.7 6.75 6.8 6.85 6.9 6.95 7.0 7.05 7.1 7.15 7.2 7.25 7.3 7.35 7.4 7.45 7.5 7.55 7.6 7.65 7.7 7.75 7.8 7.85 7.9 7.95 8.0 8.05 8.1 8.15 8.2 8.25 8.3 8.35 8.4 8.45 8.5 8.55 8.6 8.65 8.7 8.75 8.8 8.85 8.9 8.95 9.0 9.05 9.1 9.15 9.2 9.25 9.3 9.35 9.4 9.45 9.5 9.55 9.6 9.65 9.7 9.75 9.8 9.85 9.9 9.95 ]


//#define DOF							//enable depth of field (blur on non-focused objects)
//#define HQ_DOF						//Slow! Forces circular bokeh!  Uses 4 times more samples with noise in order to remove sampling artifacts at great blur sizes.
//#define HEXAGONAL_BOKEH			//disabled : circular blur shape - enabled : hexagonal blur shape
#define AUTOFOCUS
//#define FAR_BLUR_ONLY // Removes DoF on objects closer to the camera than the focus point
//lens properties
#define focal  2.4	// Centimeters	[0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3.0 3.05 3.1 3.15 3.2 3.25 3.3 3.35 3.4 3.45 3.5 3.55 3.6 3.65 3.7 3.75 3.8 3.85 3.9 3.95 4.0 4.05 4.1 4.15 4.2 4.25 4.3 4.35 4.4 4.45 4.5 4.55 4.6 4.65 4.7 4.75 4.8 4.85 4.9 4.95 5.0 5.05 5.1 5.15 5.2 5.25 5.3 5.35 5.4 5.45 5.5 5.55 5.6 5.65 5.7 5.75 5.8 5.85 5.9 5.95 6.0 6.05 6.1 6.15 6.2 6.25 6.3 6.35 6.4 6.45 6.5 6.55 6.6 6.65 6.7 6.75 6.8 6.85 6.9 6.95 7.0 7.05 7.1 7.15 7.2 7.25 7.3 7.35 7.4 7.45 7.5 7.55 7.6 7.65 7.7 7.75 7.8 7.85 7.9 7.95 8.0 8.05 8.1 8.15 8.2 8.25 8.3 8.35 8.4 8.45 8.5 8.55 8.6 8.65 8.7 8.75 8.8 8.85 8.9 8.95 9.0 9.05 9.1 9.15 9.2 9.25 9.3 9.35 9.4 9.45 9.5 9.55 9.6 9.65 9.7 9.75 9.8 9.85 9.9 9.95 ]
#define aperture  0.8		// Centimeters [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3.0 3.05 3.1 3.15 3.2 3.25 3.3 3.35 3.4 3.45 3.5 3.55 3.6 3.65 3.7 3.75 3.8 3.85 3.9 3.95 4.0 4.05 4.1 4.15 4.2 4.25 4.3 4.35 4.4 4.45 4.5 4.55 4.6 4.65 4.7 4.75 4.8 4.85 4.9 4.95 5.0 5.05 5.1 5.15 5.2 5.25 5.3 5.35 5.4 5.45 5.5 5.55 5.6 5.65 5.7 5.75 5.8 5.85 5.9 5.95 6.0 6.05 6.1 6.15 6.2 6.25 6.3 6.35 6.4 6.45 6.5 6.55 6.6 6.65 6.7 6.75 6.8 6.85 6.9 6.95 7.0 7.05 7.1 7.15 7.2 7.25 7.3 7.35 7.4 7.45 7.5 7.55 7.6 7.65 7.7 7.75 7.8 7.85 7.9 7.95 8.0 8.05 8.1 8.15 8.2 8.25 8.3 8.35 8.4 8.45 8.5 8.55 8.6 8.65 8.7 8.75 8.8 8.85 8.9 8.95 9.0 9.05 9.1 9.15 9.2 9.25 9.3 9.35 9.4 9.45 9.5 9.55 9.6 9.65 9.7 9.75 9.8 9.85 9.9 9.95 ]
#define MANUAL_FOCUS	48.0	// If autofocus is turned off, sets the focus point (meters)	[0.06948345122280154 0.07243975703425146 0.07552184450877376 0.07873506526686186 0.0820849986238988 0.08557746127787037 0.08921851740926011 0.09301448921066349 0.09697196786440505 0.10109782498721881 0.10539922456186433 0.10988363537639657 0.11455884399268773 0.11943296826671962 0.12451447144412296 0.129812176855438 0.1353352832366127 0.1410933807013415 0.1470964673929768 0.15335496684492847 0.1598797460796939 0.16668213447794653 0.17377394345044514 0.18116748694692214 0.18887560283756183 0.19691167520419406 0.20528965757990927 0.21402409717744744 0.22313016014842982 0.2326236579172927 0.2425210746356487 0.25283959580474646 0.26359713811572677 0.27481238055948964 0.2865047968601901 0.29869468928867837 0.3114032239145977 0.32465246735834974 0.3384654251067422 0.3528660814588489 0.36787944117144233 0.3835315728763107 0.39984965434484737 0.4168620196785084 0.4345982085070782 0.453089017280169 0.4723665527410147 0.49246428767540973 0.513417119032592 0.5352614285189903 0.5580351457700471 0.5817778142098083 0.6065306597126334 0.6323366621862497 0.6592406302004438 0.6872892787909722 0.7165313105737893 0.7470175003104326 0.7788007830714049 0.8119363461506349 0.8464817248906141 0.8824969025845955 0.9200444146293233 0.9591894571091382 1.0 1.0425469051899914 1.086904049521229 1.1331484530668263 1.1813604128656459 1.2316236423470497 1.2840254166877414 1.338656724353094 1.3956124250860895 1.4549914146182013 1.5168967963882134 1.5814360605671443 1.6487212707001282 1.7188692582893286 1.7920018256557555 1.8682459574322223 1.9477340410546757 2.030604096634748 2.117000016612675 2.2070718156067044 2.300975890892825 2.398875293967098 2.5009400136621287 2.6073472713092674 2.718281828459045 2.833936307694169 2.9545115270921065 3.080216848918031 3.211270543153561 3.347900166492527 3.4903429574618414 3.638846248353525 3.7936678946831774 3.955076722920577 4.123352997269821 4.298788906309526 4.4816890703380645 4.672371070304759 4.871165999245474 5.0784190371800815 5.29449005047003 5.51975421667673 5.754602676005731 5.999443210467818 6.254700951936329 6.5208191203301125 6.798259793203881 7.087504708082256 7.38905609893065 7.703437568215379 8.031194996067258 8.372897488127265 8.72913836372013 9.10053618607165 9.487735836358526 9.891409633455755 10.312258501325767 10.751013186076355 11.208435524800691 11.685319768402522 12.182493960703473 12.700821376227164 13.241202019156521 13.804574186067095 14.391916095149892 15.00424758475255 15.642631884188171 16.30817745988666 17.00203994009402 17.725424121461643 18.479586061009854 19.265835257097933 20.085536923187668 20.940114358348602 21.831051418620845 22.75989509352673 23.728258192205157 24.737822143832553 25.790339917193062 26.88763906446752 28.03162489452614 29.22428378123494 30.46768661252054 31.763992386181833 33.11545195869231 34.52441195350251 35.99331883562839 37.524723159600995 39.12128399815321 40.78577355933337 42.52108200006278 44.3302224444953 46.21633621589248 48.182698291098816 50.23272298708815 52.36996988945491 54.598150033144236 56.92113234615337 59.34295036739207 61.867809250367884 64.50009306485578 67.24437240923179 70.10541234668786 73.08818067910767 76.19785657297057 79.43983955226133 82.81975887399955 86.3434833026695 90.01713130052181 93.84708165144015 97.83998453682129 102.00277308269969 106.34267539816554 110.86722712598126 115.58428452718766 120.50203812241894 125.62902691361414 130.9741532108186 136.54669808981876 142.35633750745257 148.4131591025766 154.72767971186107 161.3108636308289 168.17414165184545 175.32943091211476 182.78915558614753 190.56626845863 198.67427341514983 ]
#include "/lib/res_params.glsl"
#ifdef DOF
	//hexagon pattern
	const vec2 hex_offsets[60] = vec2[60] (	vec2(  0.2165,  0.1250 ),
											vec2(  0.0000,  0.2500 ),
											vec2( -0.2165,  0.1250 ),
											vec2( -0.2165, -0.1250 ),
											vec2( -0.0000, -0.2500 ),
											vec2(  0.2165, -0.1250 ),
											vec2(  0.4330,  0.2500 ),
											vec2(  0.0000,  0.5000 ),
											vec2( -0.4330,  0.2500 ),
											vec2( -0.4330, -0.2500 ),
											vec2( -0.0000, -0.5000 ),
											vec2(  0.4330, -0.2500 ),
											vec2(  0.6495,  0.3750 ),
											vec2(  0.0000,  0.7500 ),
											vec2( -0.6495,  0.3750 ),
											vec2( -0.6495, -0.3750 ),
											vec2( -0.0000, -0.7500 ),
											vec2(  0.6495, -0.3750 ),
											vec2(  0.8660,  0.5000 ),
											vec2(  0.0000,  1.0000 ),
											vec2( -0.8660,  0.5000 ),
											vec2( -0.8660, -0.5000 ),
											vec2( -0.0000, -1.0000 ),
											vec2(  0.8660, -0.5000 ),
											vec2(  0.2163,  0.3754 ),
											vec2( -0.2170,  0.3750 ),
											vec2( -0.4333, -0.0004 ),
											vec2( -0.2163, -0.3754 ),
											vec2(  0.2170, -0.3750 ),
											vec2(  0.4333,  0.0004 ),
											vec2(  0.4328,  0.5004 ),
											vec2( -0.2170,  0.6250 ),
											vec2( -0.6498,  0.1246 ),
											vec2( -0.4328, -0.5004 ),
											vec2(  0.2170, -0.6250 ),
											vec2(  0.6498, -0.1246 ),
											vec2(  0.6493,  0.6254 ),
											vec2( -0.2170,  0.8750 ),
											vec2( -0.8663,  0.2496 ),
											vec2( -0.6493, -0.6254 ),
											vec2(  0.2170, -0.8750 ),
											vec2(  0.8663, -0.2496 ),
											vec2(  0.2160,  0.6259 ),
											vec2( -0.4340,  0.5000 ),
											vec2( -0.6500, -0.1259 ),
											vec2( -0.2160, -0.6259 ),
											vec2(  0.4340, -0.5000 ),
											vec2(  0.6500,  0.1259 ),
											vec2(  0.4325,  0.7509 ),
											vec2( -0.4340,  0.7500 ),
											vec2( -0.8665, -0.0009 ),
											vec2( -0.4325, -0.7509 ),
											vec2(  0.4340, -0.7500 ),
											vec2(  0.8665,  0.0009 ),
											vec2(  0.2158,  0.8763 ),
											vec2( -0.6510,  0.6250 ),
											vec2( -0.8668, -0.2513 ),
											vec2( -0.2158, -0.8763 ),
											vec2(  0.6510, -0.6250 ),
											vec2(  0.8668,  0.2513 ));

	const vec2 offsets[60] = vec2[60]  (  vec2( 0.0000, 0.2500 ),
									vec2( -0.2165, 0.1250 ),
									vec2( -0.2165, -0.1250 ),
									vec2( -0.0000, -0.2500 ),
									vec2( 0.2165, -0.1250 ),
									vec2( 0.2165, 0.1250 ),
									vec2( 0.0000, 0.5000 ),
									vec2( -0.2500, 0.4330 ),
									vec2( -0.4330, 0.2500 ),
									vec2( -0.5000, 0.0000 ),
									vec2( -0.4330, -0.2500 ),
									vec2( -0.2500, -0.4330 ),
									vec2( -0.0000, -0.5000 ),
									vec2( 0.2500, -0.4330 ),
									vec2( 0.4330, -0.2500 ),
									vec2( 0.5000, -0.0000 ),
									vec2( 0.4330, 0.2500 ),
									vec2( 0.2500, 0.4330 ),
									vec2( 0.0000, 0.7500 ),
									vec2( -0.2565, 0.7048 ),
									vec2( -0.4821, 0.5745 ),
									vec2( -0.6495, 0.3750 ),
									vec2( -0.7386, 0.1302 ),
									vec2( -0.7386, -0.1302 ),
									vec2( -0.6495, -0.3750 ),
									vec2( -0.4821, -0.5745 ),
									vec2( -0.2565, -0.7048 ),
									vec2( -0.0000, -0.7500 ),
									vec2( 0.2565, -0.7048 ),
									vec2( 0.4821, -0.5745 ),
									vec2( 0.6495, -0.3750 ),
									vec2( 0.7386, -0.1302 ),
									vec2( 0.7386, 0.1302 ),
									vec2( 0.6495, 0.3750 ),
									vec2( 0.4821, 0.5745 ),
									vec2( 0.2565, 0.7048 ),
									vec2( 0.0000, 1.0000 ),
									vec2( -0.2588, 0.9659 ),
									vec2( -0.5000, 0.8660 ),
									vec2( -0.7071, 0.7071 ),
									vec2( -0.8660, 0.5000 ),
									vec2( -0.9659, 0.2588 ),
									vec2( -1.0000, 0.0000 ),
									vec2( -0.9659, -0.2588 ),
									vec2( -0.8660, -0.5000 ),
									vec2( -0.7071, -0.7071 ),
									vec2( -0.5000, -0.8660 ),
									vec2( -0.2588, -0.9659 ),
									vec2( -0.0000, -1.0000 ),
									vec2( 0.2588, -0.9659 ),
									vec2( 0.5000, -0.8660 ),
									vec2( 0.7071, -0.7071 ),
									vec2( 0.8660, -0.5000 ),
									vec2( 0.9659, -0.2588 ),
									vec2( 1.0000, -0.0000 ),
									vec2( 0.9659, 0.2588 ),
									vec2( 0.8660, 0.5000 ),
									vec2( 0.7071, 0.7071 ),
									vec2( 0.5000, 0.8660 ),
									vec2( 0.2588, 0.9659 ));

const vec2 shadow_offsets[209] = vec2[209](vec2(0.8886414f , 0.07936136f),
vec2(0.8190064f , 0.1900164f),
vec2(0.8614115f , -0.06991258f),
vec2(0.7685533f , 0.03792081f),
vec2(0.9970094f , 0.02585129f),
vec2(0.9686818f , 0.1570935f),
vec2(0.9854341f , -0.09172997f),
vec2(0.9330608f , 0.3326486f),
vec2(0.8329557f , -0.2438523f),
vec2(0.664771f , -0.0837701f),
vec2(0.7429124f , -0.1530652f),
vec2(0.9506453f , -0.2174281f),
vec2(0.8192949f , 0.3485171f),
vec2(0.6851269f , 0.2711877f),
vec2(0.7665657f , 0.5014166f),
vec2(0.673241f , 0.3793408f),
vec2(0.6981376f , 0.1465924f),
vec2(0.6521665f , -0.2384985f),
vec2(0.5145761f , -0.05752508f),
vec2(0.5641244f , -0.169443f),
vec2(0.5916035f , 0.06004957f),
vec2(0.57079f , 0.234188f),
vec2(0.509311f , 0.1523665f),
vec2(0.4204576f , 0.05759521f),
vec2(0.8200846f , -0.3601041f),
vec2(0.6893264f , -0.3473432f),
vec2(0.4775535f , -0.3062558f),
vec2(0.438106f , -0.1796866f),
vec2(0.4056528f , -0.08251233f),
vec2(0.5771964f , 0.5502692f),
vec2(0.5094061f , 0.4025192f),
vec2(0.6908483f , 0.572951f),
vec2(0.5379036f , -0.4542191f),
vec2(0.8167359f , -0.4793735f),
vec2(0.6829269f , -0.4557574f),
vec2(0.5725697f , -0.3477072f),
vec2(0.5767449f , -0.5782524f),
vec2(0.3979413f , -0.4172934f),
vec2(0.4282598f , -0.5145645f),
vec2(0.938814f , -0.3239739f),
vec2(0.702452f , -0.5662871f),
vec2(0.2832307f , -0.1285671f),
vec2(0.3230537f , -0.2691054f),
vec2(0.2921676f , -0.3734582f),
vec2(0.2534037f , -0.4906001f),
vec2(0.4343273f , 0.5223463f),
vec2(0.3605334f , 0.3151571f),
vec2(0.3498518f , 0.451428f),
vec2(0.3230703f , 0.00287089f),
vec2(0.1049206f , -0.1476725f),
vec2(0.2063161f , -0.2608192f),
vec2(0.7266634f , 0.6725333f),
vec2(0.4027067f , -0.6185485f),
vec2(0.2655533f , -0.5912259f),
vec2(0.4947965f , 0.3025357f),
vec2(0.5760762f , 0.68844f),
vec2(0.4909205f , -0.6975324f),
vec2(0.8609334f , 0.4559f),
vec2(0.1836646f , 0.03724086f),
vec2(0.2878554f , 0.178938f),
vec2(0.3948484f , 0.1618928f),
vec2(0.3519658f , -0.7628763f),
vec2(0.6338583f , -0.673193f),
vec2(0.5511802f , -0.8283072f),
vec2(0.4090595f , -0.8717521f),
vec2(0.1482169f , -0.374728f),
vec2(0.1050598f , -0.2613987f),
vec2(0.4210334f , 0.6578422f),
vec2(0.2430464f , 0.4383665f),
vec2(0.3329675f , 0.5512741f),
vec2(0.2147711f , 0.3245511f),
vec2(0.1227196f , 0.2529026f),
vec2(-0.03937457f , 0.156439f),
vec2(0.05618772f , 0.06690486f),
vec2(0.06519571f , 0.3974038f),
vec2(0.1360903f , 0.1466078f),
vec2(-0.00170609f , 0.3089452f),
vec2(0.1357622f , -0.5088975f),
vec2(0.1604694f , -0.7453476f),
vec2(0.1245694f , -0.6337074f),
vec2(0.02542936f , -0.3728781f),
vec2(0.02222222f , -0.649554f),
vec2(0.09870815f , 0.5357338f),
vec2(0.2073958f , 0.5452989f),
vec2(0.216654f , -0.8935689f),
vec2(0.2422334f , 0.665805f),
vec2(0.0574713f , 0.6742729f),
vec2(0.2021346f , 0.8144029f),
vec2(0.3086587f , 0.7504997f),
vec2(0.02122174f , -0.7498575f),
vec2(-0.1551729f , 0.1809731f),
vec2(-0.1947583f , 0.06246066f),
vec2(-0.05754202f , -0.03901273f),
vec2(-0.1083095f , 0.2952235f),
vec2(-0.03259534f , -0.492394f),
vec2(-0.02488567f , -0.2081116f),
vec2(-0.1820729f , -0.1829884f),
vec2(-0.1674413f , -0.04529009f),
vec2(0.04342153f , -0.0368562f),
vec2(0.801399f , -0.5845526f),
vec2(0.3158276f , -0.9124843f),
vec2(-0.05945269f , 0.6727523f),
vec2(0.07701834f , 0.8579889f),
vec2(-0.05778154f , 0.5699022f),
vec2(0.1191713f , 0.7542591f),
vec2(-0.2578296f , 0.3630984f),
vec2(-0.1428598f , 0.4557526f),
vec2(-0.3304029f , 0.5055485f),
vec2(-0.3227198f , 0.1847367f),
vec2(-0.4183801f , 0.3412776f),
vec2(0.2538475f , 0.9317476f),
vec2(0.406249f , 0.8423664f),
vec2(0.4718862f , 0.7592828f),
vec2(0.168472f , -0.06605823f),
vec2(0.2632498f , -0.7084918f),
vec2(-0.2816192f , -0.1023492f),
vec2(-0.3161443f , 0.02489911f),
vec2(-0.4677814f , 0.08450397f),
vec2(-0.4156994f , 0.2408664f),
vec2(-0.237449f , 0.2605326f),
vec2(-0.0912179f , 0.06491816f),
vec2(0.01475127f , 0.7670643f),
vec2(0.1216858f , -0.9368939f),
vec2(0.07010741f , -0.841011f),
vec2(-0.1708607f , -0.4152923f),
vec2(-0.1345006f , -0.5842513f),
vec2(-0.09419055f , -0.3213732f),
vec2(-0.2149337f , 0.730642f),
vec2(-0.1102187f , 0.8425013f),
vec2(-0.1808572f , 0.6244397f),
vec2(-0.2414505f , -0.7063725f),
vec2(-0.2410318f , -0.537854f),
vec2(-0.1005938f , -0.7635075f),
vec2(0.1053517f , 0.9678772f),
vec2(-0.3340288f , 0.6926677f),
vec2(-0.2363931f , 0.8464488f),
vec2(-0.4057773f , 0.7786722f),
vec2(-0.5484858f , 0.1686208f),
vec2(-0.64842f , 0.02256887f),
vec2(-0.5544513f , -0.02348978f),
vec2(-0.492855f , -0.1083694f),
vec2(-0.4248196f , 0.4674786f),
vec2(-0.5873146f , 0.4072608f),
vec2(-0.6439911f , 0.3038489f),
vec2(-0.6419188f , 0.1293737f),
vec2(-0.005880734f , 0.4699725f),
vec2(-0.4239455f , 0.6250131f),
vec2(-0.1701273f , 0.9506347f),
vec2(7.665656E-05f , 0.9941212f),
vec2(-0.7070159f , 0.4426281f),
vec2(-0.7481344f , 0.3139496f),
vec2(-0.8330062f , 0.2472693f),
vec2(-0.7271438f , 0.2024286f),
vec2(-0.5179888f , 0.3149576f),
vec2(-0.8258062f , 0.3779382f),
vec2(-0.8063191f , 0.1262931f),
vec2(-0.2690676f , -0.4360798f),
vec2(-0.3714577f , -0.5887412f),
vec2(-0.3736085f , -0.4018324f),
vec2(-0.3228985f , -0.2063406f),
vec2(-0.2414576f , -0.2875458f),
vec2(-0.4720859f , -0.3823904f),
vec2(-0.4937642f , -0.2686005f),
vec2(-0.01500604f , -0.9587054f),
vec2(-0.08535925f , -0.8820614f),
vec2(-0.6436375f , -0.3157263f),
vec2(-0.5736347f , -0.4224878f),
vec2(-0.5026127f , -0.5516239f),
vec2(-0.8200902f , 0.5370023f),
vec2(-0.7196413f , 0.57133f),
vec2(-0.5849072f , 0.5917885f),
vec2(-0.1598758f , -0.9739854f),
vec2(-0.4230629f , -0.01858409f),
vec2(-0.9403627f , 0.2213769f),
vec2(-0.685889f , -0.2192711f),
vec2(-0.6693704f , -0.4884708f),
vec2(-0.7967147f , -0.3078234f),
vec2(-0.596441f , -0.1686891f),
vec2(-0.7366468f , -0.3939891f),
vec2(-0.7963406f , 0.02246814f),
vec2(-0.9177913f , 0.0929693f),
vec2(-0.9284672f , 0.3329005f),
vec2(-0.6497722f , 0.6851863f),
vec2(-0.496019f , 0.7013303f),
vec2(-0.3930301f , -0.6892192f),
vec2(-0.2122009f , -0.8777389f),
vec2(-0.3660335f , -0.801644f),
vec2(-0.386839f , -0.1191898f),
vec2(-0.7020127f , -0.0776734f),
vec2(-0.7760845f , -0.1566844f),
vec2(-0.5444778f , -0.6516482f),
vec2(-0.5331346f , 0.4946506f),
vec2(-0.3288236f , 0.9408244f),
vec2(0.5819826f , 0.8101937f),
vec2(-0.4894184f , -0.8290837f),
vec2(-0.5183194f , 0.8454953f),
vec2(-0.7665774f , -0.5223897f),
vec2(-0.6703191f , -0.6217513f),
vec2(-0.8902924f , -0.2446688f),
vec2(-0.8574848f , -0.09174173f),
vec2(-0.3544409f , -0.9239591f),
vec2(-0.969833f , -0.1172272f),
vec2(-0.8968207f , -0.4079512f),
vec2(-0.5891477f , 0.7724466f),
vec2(-0.2146262f , 0.5286855f),
vec2(-0.3762444f , -0.3014335f),
vec2(-0.9466863f , -0.008970681f),
vec2(-0.596356f , -0.7976127f),
vec2(-0.8877738f , 0.4569088f));
#endif
flat varying vec4 exposure;
flat varying vec2 rodExposureDepth;
varying vec2 texcoord;
uniform sampler2D colortex4;
uniform sampler2D colortex2;
uniform sampler2D colortex5;
uniform sampler2D colortex3;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortexA;
uniform sampler2D colortexC;
uniform sampler2D colortexD;
uniform sampler2D colortexE;

uniform sampler2D colortex0;
uniform sampler2D colortexB;
uniform sampler2D colortex9;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D noisetex;
uniform vec2 texelSize;

uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform int frameCounter;
uniform int isEyeInWater;
uniform float rainStrength;
uniform float near;
uniform float aspectRatio;
uniform float far;
#include "/lib/color_transforms.glsl"
#include "/lib/color_dither.glsl"
float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
float blueNoise(){
  return fract(texelFetch2D(noisetex, ivec2(gl_FragCoord.xy)%512, 0).a + 1.0/1.6180339887 * frameCounter);
}
float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));		// (-depth * (far - near)) = (2.0 * near)/ld - far - near
}
vec3 closestToCamera3x3()
{
	vec2 du = vec2(texelSize.x, 0.0);
	vec2 dv = vec2(0.0, texelSize.y);

	vec3 dtl = vec3(texcoord,0.) + vec3(-texelSize, texture2D(depthtex0, texcoord - dv - du).x);
	vec3 dtc = vec3(texcoord,0.) + vec3( 0.0, -texelSize.y, texture2D(depthtex0, texcoord - dv).x);
	vec3 dtr = vec3(texcoord,0.) +  vec3( texelSize.x, -texelSize.y, texture2D(depthtex0, texcoord - dv + du).x);

	vec3 dml = vec3(texcoord,0.) +  vec3(-texelSize.x, 0.0, texture2D(depthtex0, texcoord - du).x);
	vec3 dmc = vec3(texcoord,0.) + vec3( 0.0, 0.0, texture2D(depthtex0, texcoord).x);
	vec3 dmr = vec3(texcoord,0.) + vec3( texelSize.x, 0.0, texture2D(depthtex0, texcoord + du).x);

	vec3 dbl = vec3(texcoord,0.) + vec3(-texelSize.x, texelSize.y, texture2D(depthtex0, texcoord + dv - du).x);
	vec3 dbc = vec3(texcoord,0.) + vec3( 0.0, texelSize.y, texture2D(depthtex0, texcoord + dv).x);
	vec3 dbr = vec3(texcoord,0.) + vec3( texelSize.x, texelSize.y, texture2D(depthtex0, texcoord + dv + du).x);

	vec3 dmin = dmc;

	dmin = dmin.z > dtc.z? dtc : dmin;
	dmin = dmin.z > dtr.z? dtr : dmin;

	dmin = dmin.z > dml.z? dml : dmin;
	dmin = dmin.z > dtl.z? dtl : dmin;
	dmin = dmin.z > dmr.z? dmr : dmin;

	dmin = dmin.z > dbl.z? dbl : dmin;
	dmin = dmin.z > dbc.z? dbc : dmin;
	dmin = dmin.z > dbr.z? dbr : dmin;

	return dmin;
}



vec3 decode3x16(float a){
    int bf = int(a*65535.);
    return vec3(bf%32, (bf>>5)%64, bf>>11) / vec3(31,63,31);
}

float encode2x16(vec2 a){
    ivec2 bf = ivec2(a*255.);
    return float( bf.x|(bf.y<<8) ) / 65535.;
}

vec2 decode2x16(float a){
    int bf = int(a*65535.);
    return vec2(bf%256, bf>>8) / 255.;
}
float encodeNormal3x16(vec3 a){
    vec3 b  = abs(a);
    vec2 p  = a.xy / (b.x + b.y + b.z);
    vec2 sp = vec2(greaterThanEqual(p, vec2(0.0))) * 2.0 - 1.0;

    vec2 encoded = a.z <= 0.0 ? (1.0 - abs(p.yx)) * sp : p;

    encoded = encoded * 0.5 + 0.5;

    return encode2x16(encoded);
}
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
vec3 getDepthPoint(vec2 coord, float depth) {
    vec4 pos;
    pos.xy = coord;
    pos.z = depth;
    pos.w = 1.0;
    pos.xyz = pos.xyz * 2.0 - 1.0; //convert from the 0-1 range to the -1 to +1 range
    pos = gbufferProjectionInverse * pos;
    pos.xyz /= pos.w;
    
    return pos.xyz;
}

vec3 constructNormal(float depthA, vec2 texcoords, sampler2D depthtex) {
    const vec2 offsetB = vec2(0.0,0.001);
    const vec2 offsetC = vec2(0.001,0.0);
  
    float depthB = texture2D(depthtex, texcoords + offsetB).r;
    float depthC = texture2D(depthtex, texcoords + offsetC).r;
  
    vec3 A = getDepthPoint(texcoords, depthA);
	vec3 B = getDepthPoint(texcoords + offsetB, depthB);
	vec3 C = getDepthPoint(texcoords + offsetC, depthC);

	vec3 AB = normalize(B - A);
	vec3 AC = normalize(C - A);

	vec3 normal =  -cross(AB, AC);
	// normal.z = -normal.z;

	return normalize(normal);
}


vec3 decodeNormal3x16(float encoded){
    vec2 a = decode2x16(encoded);

    a = a * 2.0 - 1.0;
    vec2 b = abs(a);
    float z = 1.0 - b.x - b.y;
    vec2 sa = vec2(greaterThanEqual(a, vec2(0.0))) * 2.0 - 1.0;

    vec3 decoded = normalize(vec3(
        z < 0.0 ? (1.0 - b.yx) * sa : a.xy,
        z
    ));

    return decoded;
}

vec3 worldToView(vec3 worldPos) {

    vec4 pos = vec4(worldPos, 0.0);
    pos = gbufferModelView * pos;

    return pos.xyz;
}





vec2 pV[4];
// |0  |1
//
// |2  |3

vec2 pH[3];
//	- 2
//	- 1
//	- 0

vec2 uv;
vec2 pixel;
int SIZE = 8;
vec2 SEGMENT;
float KERNING = 1.3;
const ivec2 DIGITS = ivec2(2, 4);

void globalInit(){
    pixel = 2.0/vec2(viewWidth,viewHeight);
    SEGMENT = pixel * vec2(SIZE, 1.0);
	}

void fillNumbers(){
    pV[0] = vec2(0, SIZE);  pV[1] = vec2(SIZE - 1, SIZE);
    pV[2] = vec2(0, 0); 	pV[3] = vec2(SIZE - 1, 0);
    
    for (int i = 0; i < 3; i++)
    	pH[i] = vec2(0, SIZE * i);
    
	}

vec2 digitSegments(int d){
    vec2 v;
    if (d == 0) v = vec2(.11115, .1015);
    if (d == 1) v = vec2(.01015, .0005);
    if (d == 2) v = vec2(.01105, .1115);
    if (d == 3) v = vec2(.01015, .1115);
    if (d == 4) v = vec2(.11015, .0105);
    if (d == 5) v = vec2(.10015, .1115);
    if (d == 6) v = vec2(.10115, .1115);
    if (d == 7) v = vec2(.01015, .0015);
    if (d == 8) v = vec2(.11115, .1115);
    if (d == 9) v = vec2(.11015, .1115);
    return v;
	}

vec2 step2(vec2 edge, vec2 v){
    return vec2(step(edge.x, v.x), step(edge.y, v.y));
	}

float segmentH(vec2 pos){
    vec2 sv = step2(pos, uv) - step2(pos + SEGMENT.xy, uv);
    return step(1.1, length(sv));
	}

float segmentV(vec2 pos){
    vec2 sv = step2(pos, uv) - step2(pos + SEGMENT.yx, uv);
    return step(1.1, length(sv));
	}

float nextDigit(inout float f){
    f = fract(f) * 10.0;
    return floor(f);
	}

float drawDigit(int d, vec2 pos){
    vec4 sv = vec4(1.0, 0.0, 1.0, 0.0);
    vec3 sh = vec3(1.0);
    float c = 0.0;
    
    vec2 v = digitSegments(d);
    
    for (int i = 0; i < 4; i++)
        c += segmentV(pos + pixel.x * pV[i]) * nextDigit(v.x);

    for (int i = 0; i < 3; i++)
        c += segmentH(pos + pixel.x * pH[i]) * nextDigit(v.y);
    
	return c;
	}

float printNumber(float f, vec2 pos){
    float c = 0.0;
    f /= pow(10.0, float(DIGITS.x));
        
    for (int i = 0; i < DIGITS.x; i++){
        c += drawDigit(int(nextDigit(f)), pos);
        pos += KERNING * pixel * vec2(SIZE, 0.0);
    	}
    
    for (int i = 0; i < DIGITS.y; i++){
        pos += KERNING * pixel * vec2(SIZE, 0.0);
        c += drawDigit(int(nextDigit(f)), pos);
    	}
   	return c;
	}






vec2 tapLocation(int sampleNumber,int nb, float nbRot,float jitter,float distort)
{
    float alpha = (sampleNumber+jitter)/nb;
    float angle = jitter*6.28+alpha * nbRot * 6.28;
    float sin_v, cos_v;

	sin_v = sin(angle);
	cos_v = cos(angle);

    return vec2(cos_v, sin_v)*alpha;
}



#define s2(a, b)				temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)			s2(a, b); s2(a, c);
#define mx3(a, b, c)			s2(b, c); s2(a, c);

#define mnmx3(a, b, c)			mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)		s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)	s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges


#define vec vec3
#define toVec(x) x.rgb
vec3 median2(sampler2D tex1) {

    vec v[9];
    ivec2 ssC = ivec2(gl_FragCoord.xy);
	
	
    // Add the pixels which make up our window to the pixel array.
	
	
    for (int dX = -1; dX <= 1; ++dX) {
        for (int dY = -1; dY <= 1; ++dY) {
            ivec2 offset = ivec2(dX, dY);

            // If a pixel in the window is located at (x+dX, y+dY), put it at index (dX + R)(2R + 1) + (dY + R) of the
            // pixel array. This will fill the pixel array, with the top left pixel of the window at pixel[0] and the
            // bottom right pixel of the window at pixel[N-1].
			
			
            v[(dX + 1) * 3 + (dY + 1)] = toVec(texelFetch(tex1, ssC + offset, 0));
        }
    }

    vec temp;
    // Starting with a subset of size 6, remove the min and max each time
    mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
    mnmx5(v[1], v[2], v[3], v[4], v[6]);
    mnmx4(v[2], v[3], v[4], v[7]);
    mnmx3(v[3], v[4], v[8]);
    vec3 result = v[4].rgb;
	
	return result;

}

#include "/lib/filter.glsl"


void main() {
  /* DRAWBUFFERS:7 */
  
  float edgemask = clamp(edgefilter(texcoord*RENDER_SCALE*RENDER_SCALE,2,colortex8).rgb,0,1).r;
  float vignette = (1.5-dot(texcoord-0.5,texcoord-0.5)*2.);
  
  #ifndef firefly_supression
	vec3 col = texture2D(colortex5,texcoord).rgb;
  #else
	vec3 col =  median2(colortex5);
		 col = mix(col, texture2D(colortex5,texcoord).rgb, clamp(edgemask,0,1.0) );
  #endif
	float noise = blueNoise()*6.28318530718;
	float pcoc = 0;
globalInit();
    fillNumbers();
    uv = gl_FragCoord.xy / vec2(viewWidth,viewHeight).xy;
	#ifdef DOF
		/*--------------------------------*/
		float z = ld(texture2D(depthtex0, texcoord.st*RENDER_SCALE).r)*far;
		#ifdef AUTOFOCUS
			float focus = rodExposureDepth.y*far;
		#else
			float focus = MANUAL_FOCUS;
		#endif
		


		pcoc = (min(abs(aperture * (focal/100.0 * (z - focus)) / (z * (focus - focal/100.0))),texelSize.x*15.0));

		
		 
		#ifdef FAR_BLUR_ONLY
			pcoc *= float(z > focus);
		#endif

		mat2 noiseM = mat2( cos( noise ), -sin( noise ),
	                       sin( noise ), cos( noise )
	                         );
		vec3 bcolor = vec3(0.);
		float nb = 0.0;
		vec2 bcoord = vec2(0.0);
		/*--------------------------------*/
		#ifndef HQ_DOF
		bcolor = col;
		#ifdef HEXAGONAL_BOKEH
			for ( int i = 0; i < 60; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + hex_offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
			col = bcolor/61.0;
		#else
			for ( int i = 0; i < 60; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
		/*--------------------------------*/
	col = bcolor/61.0;
		#endif
		#endif
		#ifdef HQ_DOF
			for ( int i = 0; i < 209; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + noiseM*shadow_offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
			col = bcolor/209.0;
		#endif
#endif
	vec2 clampedRes = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.));

	vec3 bloom = texture2D(colortex3,texcoord/clampedRes*vec2(1920.,1080.)*0.5*BLOOM_QUALITY).rgb*0.5*0.14;

	float lightScat = clamp(BLOOM_STRENGTH*0.05*pow(exposure.a,0.2),0.0,1.0)*vignette;

  float VL_abs = texture2D(colortex7,texcoord*RENDER_SCALE).r;
	float purkinje = rodExposureDepth.x/(1.0+rodExposureDepth.x)*Purkinje_strength;
  VL_abs = clamp((1.0-VL_abs)*BLOOMY_FOG*0.75*(1.0-purkinje*0.3)*(1.0+rainStrength),0.0,1.0)*clamp(1.0-pow(cdist(texcoord.xy),15.0),0.0,1.0);
	col = (mix(col,bloom,VL_abs)+bloom*lightScat)*exposure.rgb;

	//Purkinje Effect
  float lum = dot(col,vec3(0.15,0.3,0.55));
	float lum2 = dot(col,vec3(0.85,0.7,0.45))/2;
	float rodLum = lum2*400.;
	float rodCurve = mix(1.0, rodLum/(2.5+rodLum), purkinje);
	col = mix(clamp(lum,0.0,0.05)*Purkinje_Multiplier*vec3(Purkinje_R, Purkinje_G, Purkinje_B)+1.5e-3, col, rodCurve);
//	col =vec3(rodCurve);
//	if (col.r > 0.85*3.0) col = vec3(100,0.0,0.0);

	#ifndef USE_ACES_COLORSPACE_APPROXIMATION
  	col = LinearTosRGB(TONEMAP(col));

	#else
		col = col * ACESInputMat;
		col = TONEMAP(col);
		col = LinearTosRGB(clamp(col * ACESOutputMat, 0.0, 1.0));
	#endif
	//col = ACESFitted(texture2D(colortex4,texcoord/3.).rgb/500.);
	gl_FragData[0].rgb = clamp(int8Dither(col,texcoord),0.0,1.0);
	
//    gl_FragData[0].rgb += vec3(printNumber(RENDER_SCALE.x, vec2(0.5)));
//   gl_FragData[0].rgb += vec3(printNumber((averageFrameTime), vec2(0.6)));


//  gl_FragData[0].rgb = vec3(texture2D(colortexA,texcoord*RENDER_SCALE).aaa);



//    gl_FragData[0].rgb = constructNormal(texture2D(depthtex0, texcoord.st*RENDER_SCALE).r, texcoord*RENDER_SCALE, depthtex0);
	//if (nightMode < 0.99 && texcoord.x < 0.5)	gl_FragData[0].rgb =vec3(0.0,1.0,0.0);

}
