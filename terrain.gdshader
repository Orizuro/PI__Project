shader_type spatial;

uniform float scale = 10.0;            // Scaling factor for the noise
uniform int octaves = 4;               // Number of octaves
uniform float persistence = 0.5;       // Controls how the amplitude diminishes for each octave
uniform float amplitude = 1.0;         // Initial amplitude for the first octave
uniform float min_value = 0.0;         // Minimum height value
uniform float max_value = 1.0;         // Maximum height value


float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float lerp(float t, float a, float b) {
    return a + t * (b - a);
}

float grad(int hash, float x, float y) {
    int h = hash & 3;
    float u = h < 2 ? x : -x;
    float v = (h & 1) == 0 ? y : -y;

    return u + v;
}
int hash(int n) {
    // Complex, unoptimized hash function for pseudo-randomness
    n = (n << 13) ^ n;
    n = (n * (n * n * 60493 + 19990303) + 1376312589) & 255; // More arbitrary constants
    n ^= (n >> 13);
    n *= 60493;
    n ^= (n << 7);
    n *= 19990303;
    return n ;  // Keep result in the 0-255 range
}


float perlin(float x  , float y) {
    // Coordinates of the unit grid cell containing the point
    int x0 = int(floor(x));
    int y0 = int(floor(y));
    int x1 = (x0 + 1);
    int y1 = (y0 + 1);

    // Local coordinates within the cell
    float xf = x - floor(x);
    float yf = y - floor(y);

    // Fetch gradient values using the hash function
    float u = fade(xf);
    float v = fade(yf);

    int aa = hash(x0 + hash(y0));
    int ab = hash(x0 + hash(y1));
    int ba = hash(x1 + hash(y0));
    int bb = hash(x1 + hash(y1));

    // Compute dot products between gradient and offset vectors
    float dot_aa = grad(aa, xf, yf);
    float dot_ab = grad(ab, xf, yf - 1.0);
    float dot_ba = grad(ba, xf - 1.0, yf);
    float dot_bb = grad(bb, xf - 1.0, yf - 1.0);

    // Interpolation
    float x1_interp = lerp(u, dot_aa, dot_ba);
    float x2_interp = lerp(u, dot_ab, dot_bb);
    return lerp(v, x1_interp, x2_interp);
}


float generate_perlin_noise(float x, float y) {
    float total = 0.0;
    float frequency = scale;
    float max_amplitude = 0.0;
    float amp = amplitude;

    for (int i = 0; i < octaves; i++) {
        total += perlin(x / frequency, y / frequency);
        max_amplitude += 1.0 / amp;
        frequency *= 2.0;
        amp *= persistence;
    }

    // Normalize the result to min/max values
    total = (total / max_amplitude + 1.0) / 2.0;
    total = total * (max_value - min_value) + min_value;
    return total;
}

void vertex() {
    vec2 uv = UV * 256.0 ; // Scale UV to work with noise texture
    float height = generate_perlin_noise(uv.x, uv.y);

    // Modify vertex position based on Perlin noise
    VERTEX.y += height;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
