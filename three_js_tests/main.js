// example code from https://threejs.org/docs/index.html#manual/en/introduction/Creating-a-scene
import * as THREE from 'three'

// instantiate scene
const scene = new THREE.Scene();

// camera
const fov = 75;
const aspect_ratio = window.innerWidth / window.innerHeight;
const near = 0.1;
const far = 1000;
const camera = new THREE.PerspectiveCamera(fov, aspect_ratio, near, far);

// create and add renderer to document
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// create cube
const cube_geometry = new THREE.BoxGeometry(1, 1, 1);
const cube_material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(cube_geometry, cube_material);
scene.add(cube);

// move camera because else the camera is inside the cube
camera.position.z = 5;

// render loop
function animate() {
    requestAnimationFrame(animate);

    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;

    // render scene
    renderer.render(scene, camera);
}
animate();