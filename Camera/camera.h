// -*-C++-*-

#pragma once

#define MAX_CLIP_PLANES  6

#include <string>
#include "vector3.h"
#include "plane.h"
#include "bbox.h"
#include "trfm3D.h"

// Class to store position / orientation of a Camera
struct CameraFrame {
	CameraFrame() {}
	CameraFrame(const Vector3 & E,
				const Vector3 & R,
				const Vector3 & U,
				const Vector3 & D) : m_E(E), m_R(R), m_U(U), m_D(D) {}
	Vector3 m_E;
	Vector3 m_R;
	Vector3 m_U;
	Vector3 m_D;
};

class Camera {

public:
	enum type {
		invalid,
		perspective,
		orthographic
	};

	/**
	   Set the viewing matrix derived from a camera at position E, looking
	   at point "at" and whose up vector is "up"
	*/
	void lookAt(const Vector3 & E,
				const Vector3 & at,
				const Vector3 & up);

	/**
	   Get the current position/orientation.
	*/
	CameraFrame getFrame() const ;

	/**
	   Set a position/orientation.
	*/
	void setFrame(const CameraFrame & frame);

	/**
	 * Call this function whenever the viewport changes (in GLUT glutReshapeFunc
	 * function)
	 *
	 */
	virtual void onResize(int width, int height ) = 0;

	/**
	 * Change camera's zoom angle (fovy)
	 *
	 * inOut: true -> zoom in
	 * inOut: false -> zoom out
	 *
	 * note: Only affects perspective cameras.
	 */
	virtual void zoom(float angle);

	/**
	 * Get zoom angle.
	 *
	 * note: Only useful perspective cameras.
	 */
	virtual float getZoom() const;

	////////////////////////////////////////////////
	// get/set

	void setName(const std::string &name);
	const char *getName() const;
	const std::string & getNameString() const;
	void setFar(float far);      //!< Set far plane distance (positive)
	float getFar() const;        //!< Get far plane distance (positive)
	void setNear(float near);    //!< Set near plane distance (positive)
	float getNear() const;       //!< Get near plane distance (positive)
	Vector3 getPosition() const;  //!< Get camera position in world coordinates.
	Vector3 getDirection() const; //!< Get camera direction (the vector the camera is aiming at) in world coordinates
	Vector3 getUp() const; //!< Get camera up vector in world coordinates

	////////////////////////////////////////////////
	// trfm transformations

	const Trfm3D *viewTrfm() const;       // Return the View transformation of the Camera
	const Trfm3D *projectionTrfm() const; // Get the trfm with the camera projection

	// Get projections a-la OpenGL.
	// gmatrix has to have space to store 16 floats
	void viewTrfmGL(float *gmatrix) const;
	void projectionTrfmGL(float *gmatrix) const;

	////////////////////////////////////////////////
	// Movement

	void fly(float step); // Move the camera "step" units. Fly mode.
	void walk(float step); // Move the camera "step" units. Walk mode.
	void panX(float step ); // Pan camera left/right
	void panY(float step ); // Pan camera up/down

	////////////////////////////////////////////////
	// Rotation

	void pitch(float angle);       // rotate aroud local axis R
	void yaw(float angle);         // rotate aroud local axis U
	void roll(float angle);        // rotate aroud local axis D
	void viewYWorld(float angle ); // Rotate camera around world Y axis. Use this instead of "yaw" when walking.

	// Arc rotations
	//
	// axis is vector that goes from E to At
	// centre of rotation is At
	void arcOverUnder(float angle ); // up/down
	void arcLeftRight(float angle ); // left/right

	/**
	 *	Check wether frustum intersects a bounding box.
	 *
	 * @param thisCamera the Camera.
	 * @param theBBox the Bounding Box (in world coordinates).
	 * @param planesBitM points to a bitmask where bit i is set if BBOX fully inside the i-th frustum plane.
	 *
	 * @return
	 *     -1 BBOX fully inside
	 *     0  BBOX intersects frustum
	 *     +1 BBOX fully outside frustum
	 */

	int checkFrustum(const BBox *theBBox, unsigned int *planesBitM);

	friend class CameraManager;

	virtual void print();

protected:
	/**
	 * Create a camera with these parameters:
	 *
	 * - located at (0, 0, 0)
	 * - look at (0, 0, -1)
	 * - up vector (0, 1, 0)
	 */
	Camera();
	virtual ~Camera();

	virtual void updateProjection() = 0;
	void updateFrustumPlanes();

	int m_type;         //!< Camera type (see Camera::type)
	std::string m_name; //!< Name of the Camera

	////////////////////////////////////////////////
	// Projection

	float m_left, m_right;
	float m_bottom, m_top;
	float m_near, m_far; // m_far > m_near (distance from plane to camera origin)

	////////////////////////////////////////////////
	// Transformations
	Trfm3D *m_viewTrfm; // the View transformation
	Trfm3D *m_projTrfm; // projection transformation

	Camera(const Camera &);
	Camera & operator=(Camera &);

	void updateFrame();
	void setViewTrfm();

	Vector3 m_lastE, m_lastAt, m_lastUp;

	////////////////////////////////////////////////
	// View transformation

	Vector3 m_E;  // View point (default 0, 0  0)
	Vector3 m_R; //!< right vector (in world coordinates)
	Vector3 m_U; //!< left vector (in world coordinates)
	Vector3 m_D; //!< back vector (in world coordinates)


	Plane *m_fPlanes[MAX_CLIP_PLANES]; // Frustum planes. A 6 elements of type plane. Order: (l,r,b,t,n,f)
									   // Note: normals point outside the frustum.
};

class PerspectiveCamera : public Camera {

public:

	//	* Set perspective parameters of a camera
	//	*
	//	* @param thisCamera the Camera to be changed
	//	* @param fovy field of view in the y direction
	//	* @param aspect aspect ratio (widht / heigth)
	//	* @param near distance of the near plane
	//	* @param far distance of the far plane
	//	*/
	void init(float fovy, float aspect,
			  float near, float far); //!< Set perspective camera

	void onResize(int w, int h );
	void zoom(float angle);
	float getZoom() const;
	void print();

	friend class CameraManager;

private:

	// projective parameters
	// * - perspective projection
	// * - aperture (fovy) = 60 degrees
	// * - aspect ratio = 1
	PerspectiveCamera();
	~PerspectiveCamera();
	PerspectiveCamera(const PerspectiveCamera &);
	PerspectiveCamera & operator=(PerspectiveCamera &);
	void updateProjection();
	////////////////////////////////////////////////
	// Projection
	float    m_fovy; //!< field of view radians in U direction
	float    m_aspectRatio; //!< window system dependent

};

class OrthographicCamera : public Camera {

public:

	void onResize(int w, int h);
	/*
	 * Set orthographic parameters of a camera
	 *
	 * @param thisCamera the Camera to be changed
	 * @param left distance of left clipping plane
	 * @param right distance of right clipping plabe
	 * @param top distance of top clipping plane
	 * @param bottom distance of bottom clipping plane
	 * @param near distance of near clipping plane
	 * @param far distance of far clipping plane
	 */
	void init(float left, float right,
			  float bottom, float top,
			  float near, float far); //!< Set orthographic camera

	void setFovy(float angle);
	void print();

	friend class CameraManager;

private:
	// orthographic
	OrthographicCamera();
	~OrthographicCamera();
	OrthographicCamera(const OrthographicCamera &);
	OrthographicCamera & operator=(OrthographicCamera &);

	void zoom(float angle);

	void updateProjection();
};
