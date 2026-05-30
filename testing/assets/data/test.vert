out vec2 vUV;

uniform float iTime;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    vUV = aUV;
}