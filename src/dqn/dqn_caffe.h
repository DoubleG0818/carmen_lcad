
#ifndef __DQN_H_
#define __DQN_H_

#include <vector>
#include <deque>
#include <string>
#include <caffe/caffe.hpp>
#include <caffe/solver.hpp>
#include <caffe/layer.hpp>
#include <caffe/layers/memory_data_layer.hpp>

/** @filipe: deveriam ter 2 redes e 2 conjuntos de acoes, um para velocidade e outro para steering **/
enum DqnAction
{
	DQN_ACTION_NONE = 0,
	DQN_ACTION_SPEED_UP,
	DQN_ACTION_SPEED_DOWN,
	DQN_ACTION_STEER_LEFT,
	DQN_ACTION_STEER_RIGHT
};


std::string action_to_string(DqnAction a);


class DqnParams
{
public:
	bool USE_GPU;  					// "Use GPU to brew Caffe"
	char* SOLVER_FILE; 				// "Solver parameter file (*.prototxt)"
	long REPLAY_MEMORY_SIZE; 		// "Capacity of replay memory"
	long NUM_ITERATIONS; 			// "Number of iterations needed for epsilon to reach 0.1"
	double GAMMA; 					// "Discount factor of future rewards (0,1]"
	int NUM_WARMUP_TRANSITIONS;		// "Enough amount of transitions to start learning"
	int SKIP_FRAME; 				// "Number of frames skipped"
	char *MODEL_FILE; 				// "Model file to load"
	bool EVALUATION_MODE;			// "Evaluation mode: only playing a game, no updates"
	double EVALUATE_WITH_EPSILON; 	// "Epsilon value to be used in evaluation mode"
	int REPEAT_GAMES; 				// "Number of games played in evaluation mode"

	static const int kRawFrameHeight = 210;
	static const int kRawFrameWidth = 160;
	static const int kCroppedFrameSize = 84;
	static const int kCroppedFrameDataSize = kCroppedFrameSize * kCroppedFrameSize;
	static const int kInputFrameCount = 4;
	static const int kInputDataSize = kCroppedFrameDataSize * kInputFrameCount;
	static const int kMinibatchSize = 32;
	static const int kMinibatchDataSize = kInputDataSize * kMinibatchSize;
	static const float kGamma = 0.95f;
	static const int kOutputCount = 5;

	DqnParams()
	{
		USE_GPU = true;
		SOLVER_FILE = "dqn_solver.prototxt";
		REPLAY_MEMORY_SIZE = 500000;
		NUM_ITERATIONS = 1000000;
		GAMMA = 0.95;
		NUM_WARMUP_TRANSITIONS = 500;
		SKIP_FRAME = 0;
		MODEL_FILE = "";
		EVALUATION_MODE = false;
		EVALUATE_WITH_EPSILON = 0.05;
		REPEAT_GAMES = 1;
	}
};


template<class T, size_t array_size>
class MyArray : public std::vector<T>
{
public:
	MyArray<T, array_size>() : std::vector<T>(/*array_size*/)
	{
		this->reserve(array_size);
	}
};


typedef MyArray<uint8_t, DqnParams::kCroppedFrameDataSize> FrameData;
typedef boost::shared_ptr<FrameData> FrameDataSp;
typedef MyArray<FrameDataSp, DqnParams::kInputFrameCount> InputFrames;


typedef MyArray<float, DqnParams::kMinibatchDataSize> FramesLayerInputData;
typedef MyArray<float, DqnParams::kMinibatchSize * DqnParams::kOutputCount> TargetLayerInputData;
typedef MyArray<float, DqnParams::kMinibatchSize * DqnParams::kOutputCount> FilterLayerInputData;
typedef MyArray<float, DqnParams::kMinibatchSize * 2> OdometryLayerInputData;


//typedef std::tuple<InputFrames, DqnAction, float, boost::optional<FrameDataSp> > Transition;
class Transition
{
public:
	InputFrames input_frames;
	DqnAction action;
	boost::shared_ptr<FrameData> frame_data;
	double reward;
	double v, phi;

	Transition() { reward = 0; action = DQN_ACTION_NONE; v = phi = 0; }

	Transition(InputFrames input_frames_param,
			DqnAction action_param,
			double reward_param,
			boost::shared_ptr<FrameData> frame_data_param,
			double v_param, double phi_param)
	{
		input_frames = input_frames_param;
		action = action_param;
		frame_data = frame_data_param;
		reward = reward_param;
		phi = phi_param;
		v = v_param;
	}
};


class DqnCaffe
{
	DqnParams _params;

	boost::shared_ptr<caffe::Blob<float> > q_values_blob_;
	boost::shared_ptr<caffe::Solver<float> > solver_;
	boost::shared_ptr<caffe::Net<float> > net_;

	//const ActionVect legal_actions_;
	std::vector<DqnAction> legal_actions_;
	std::string solver_param_;

	size_t replay_memory_capacity_;
	int current_iter_;
	double gamma_;

	std::deque<Transition> replay_memory_;

	boost::shared_ptr<caffe::MemoryDataLayer<float> > frames_input_layer_;
	boost::shared_ptr<caffe::MemoryDataLayer<float> > target_input_layer_;
	boost::shared_ptr<caffe::MemoryDataLayer<float> > filter_input_layer_;
	boost::shared_ptr<caffe::MemoryDataLayer<float> > odometry_input_layer_;

	TargetLayerInputData dummy_input_data_;

	void InputDataIntoLayers(const FramesLayerInputData& frames_data,
			const TargetLayerInputData& target_data,
			const FilterLayerInputData& filter_data,
			const OdometryLayerInputData &odometry_input);

	std::pair<DqnAction, float> SelectActionGreedily(const InputFrames& last_frames, double v, double phi);
	std::vector<std::pair<DqnAction, float> > SelectActionGreedily(const std::vector<InputFrames>& last_frames, const std::vector<float>& v_batch, const std::vector<float>& phi_batch);

public:

	DqnCaffe(DqnParams params, char *program_name);

	/**
	 * Initialize DQN. Must be called before calling any other method.
	 */
	void Initialize();

	/**
	 * Load a trained model from a file.
	 */
	void LoadTrainedModel(const std::string& model_file);

	/**
	 * Select an action by epsilon-greedy.
	 */
	DqnAction SelectAction(const InputFrames& last_frames, double epsilon, double v, double phi);

	/**
	 * Add a transition to replay memory
	 */
	void AddTransition(const Transition& transition);

	/**
	 * Update DQN using one minibatch
	 */
	void Update();

	int memory_size() const { return replay_memory_.size(); }
	int current_iteration() const { return current_iter_; }
	DqnParams* params() { return &_params; }
};


#endif
