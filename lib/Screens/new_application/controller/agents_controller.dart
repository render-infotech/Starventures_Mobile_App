// lib/controller/agents_controller.dart
import 'package:get/get.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/agents_model.dart';

class AgentsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable variables
  var agents = <AgentModel>[].obs;
  var selectedAgent = Rx<AgentModel?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    try {
      isLoading(true);
      errorMessage('');

      // Use ApiClient to fetch agents with proper authentication
      final agentsResponse = await _apiClient.fetchAgents();

      if (agentsResponse.success) {
        agents.value = agentsResponse.data;
        print('✅ Successfully fetched ${agents.length} agents');

        // Log each agent for debugging
        for (var agent in agents) {
          print('Agent: ${agent.name} (ID: ${agent.id}, Branch: ${agent.branchId})');
        }
      } else {
        errorMessage(agentsResponse.message.isNotEmpty
            ? agentsResponse.message
            : 'Failed to fetch agents');
        print('❌ API returned success: false - ${agentsResponse.message}');
      }
    } catch (e) {
      errorMessage('Network error: $e');
      print('❌ Exception while fetching agents: $e');
    } finally {
      isLoading(false);
    }
  }

  void selectAgent(AgentModel? agent) {
    selectedAgent.value = agent;
    print('Selected agent: ${agent?.name} (ID: ${agent?.id})');
  }

  int? getSelectedAgentId() {
    return selectedAgent.value?.id;
  }

  String? getSelectedAgentName() {
    return selectedAgent.value?.name;
  }

  void clearSelection() {
    selectedAgent.value = null;
  }

  Future<void> refreshAgents() async {
    await fetchAgents();
  }

  List<AgentModel> searchAgents(String query) {
    if (query.isEmpty) return agents;

    return agents.where((agent) =>
        agent.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  AgentModel? getAgentById(int id) {
    try {
      return agents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isAgentSelected() {
    return selectedAgent.value != null;
  }

  String? getValidationError() {
    if (!isAgentSelected()) {
      return 'Please select an agent';
    }
    return null;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
