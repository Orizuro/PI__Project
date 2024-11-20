shader_type spatial;

uniform float scale = 10.0;            // Scaling factor for the noise
uniform int octaves = 4;               // Number of octaves
uniform float persistence = 0.5;       // Controls how the amplitude diminishes for each octave
uniform float amplitude = 1.0;         // Initial amplitude for the first octave
uniform float min_value = 0.0;         // Minimum height value
uniform float max_value = 1.0;         // Maximum height value
uniform int seed = 0;                  // Seed parameter for the noise generator

// Predefined list of gradient vectors
const vec2 gradients[9] = vec2[](
    vec2(1.0, 1.0), vec2(-1.0, 1.0),
    vec2(1.0, -1.0), vec2(-1.0, -1.0),
    vec2(1.0, 0.0), vec2(-1.0, 0.0),
    vec2(0.0, 1.0), vec2(0.0, -1.0),
	vec2(0.0, 0.0)
);

float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float lerp(float t, float a, float b) {
    return a + t * (b - a);
}

vec2 get_random_gradient(int seed_value) {
    return gradients[seed_value % 9];
}

int hash(int n) {
    n = (n << 13) ^ n;
    n = (n * (n * n * 60493 + 19990303) + 1376312589 + seed) & 255;
    return n;
}

float grad(int hash, float x, float y) {
    vec2 gradient = get_random_gradient(hash);
    return dot(gradient, vec2(x, y));
}

float perlin(float x, float y) {
    int x0 = int(floor(x));
    int y0 = int(floor(y));
    int x1 = (x0 + 1);
    int y1 = (y0 + 1);


    float xf = x - float(x0);
    float yf = y - float(y0);

    float u = fade(xf);
    float v = fade(yf);

    int aa = hash(x0 + hash(y0));
    int ab = hash(x0 + hash(y1));
    int ba = hash(x1 + hash(y0));
    int bb = hash(x1 + hash(y1));

    float dot_aa = grad(aa, xf, yf);
    float dot_ab = grad(ab, xf, yf - 1.0);
    float dot_ba = grad(ba, xf - 1.0, yf);
    float dot_bb = grad(bb, xf - 1.0, yf - 1.0);

    float x1_interp = lerp(u, dot_aa, dot_ba);
    float x2_interp = lerp(u, dot_ab, dot_bb);
    return lerp(v, x1_interp, x2_interp);
}

float generate_perlin_noise(float x, float y) {
    float total = 0.0;
    float frequency = scale;
    float max_amplitude = amplitude;

	total += perlin(x / frequency, y / frequency);

    for (int i = 0; i < octaves; i++) {
		frequency *= 0.2;
        total += perlin(x / frequency, y / frequency) * persistence;


        //amp *= persistence;
    }


    total = (total / max_amplitude + 1.0) / 2.0;
    total = total * (max_value - min_value) + min_value;
    return total;
}

void vertex() {
    vec2 uv = UV * 256.0;
    float height = generate_perlin_noise(uv.x, uv.y);

    VERTEX.y += height;
}

void fragment() {

}
