in vec2 vUV;
out vec4 FragColor;

void main() {
    vec4 color = texture(tex, vUV);
    FragColor = mix(color, vec4(0, 1, 0, 1), 0.25);
}